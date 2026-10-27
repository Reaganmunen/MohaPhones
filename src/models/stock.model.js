const { query, withTransaction, inTx } = require('../config/db');
const { AppError, notFound } = require('../utils/errors');
const units = require('./unit.model');

/**
 * STOCK RULES (enforced by the database, see schema):
 *  - stock_movements is an append-only ledger; balances are cached in stock_levels /
 *    batch_stock_levels with CHECK (on_hand >= 0), so overselling raises INSUFFICIENT_STOCK.
 *  - Phones don't expire, so stock is tracked per product and location only (no batches).
 */

async function applyMovement(db, m) {
  const { rows: [row] } = await query(
    `INSERT INTO stock_movements
       (product_id, batch_id, location_id, quantity, movement_type, unit_cost, source_type, source_id, note, created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
    [m.product_id, m.batch_id || null, m.location_id, m.quantity, m.movement_type,
      m.unit_cost ?? null, m.source_type || null, m.source_id || null, m.note || null, m.created_by || null], db);
  return row;
}

/**
 * Turn "move `quantity` of this product" into ledger slices [{batch_id, quantity}].
 * quantity is signed (+ in, - out). There are no batches any more, so it is always a single slice with no batch.
 * (Kept as a function so every caller still checks that the product exists.)
 */
async function expandToBatches(db, { product_id, quantity }) {
  const { rows: [p] } = await query('SELECT id FROM products WHERE id = $1', [product_id], db);
  if (!p) throw notFound('Product');
  return [{ batch_id: null, quantity }];
}

// ---------------------------------------------------------------- reading stock
async function getLevels({ product_id, location_id } = {}, db) {
  const params = []; const where = [];
  if (product_id) { params.push(product_id); where.push(`sl.product_id = $${params.length}`); }
  if (location_id) { params.push(location_id); where.push(`sl.location_id = $${params.length}`); }
  const { rows } = await query(
    `SELECT sl.product_id, p.name, p.sku, sl.location_id, l.name AS location, sl.on_hand
       FROM stock_levels sl JOIN products p ON p.id = sl.product_id JOIN locations l ON l.id = sl.location_id
      ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY p.name, l.id`, params, db);
  return rows;
}

async function listMovements({ product_id, location_id, movement_type, from, to, limit = 100, offset = 0 } = {}, db) {
  const params = []; const where = [];
  if (product_id) { params.push(product_id); where.push(`m.product_id = $${params.length}`); }
  if (location_id) { params.push(location_id); where.push(`m.location_id = $${params.length}`); }
  if (movement_type) { params.push(movement_type); where.push(`m.movement_type = $${params.length}`); }
  if (from) { params.push(from); where.push(`m.created_at >= ($${params.length}::date)::timestamp AT TIME ZONE 'Africa/Nairobi'`); }
  if (to) { params.push(to); where.push(`m.created_at < (($${params.length}::date) + 1)::timestamp AT TIME ZONE 'Africa/Nairobi'`); }
  params.push(limit, offset);
  const { rows } = await query(
    `SELECT m.*, p.name AS product_name, u.name AS user_name
       FROM stock_movements m JOIN products p ON p.id = m.product_id
       LEFT JOIN users u ON u.id = m.created_by
      ${where.length ? 'WHERE ' + where.join(' AND ') : ''}
      ORDER BY m.id DESC LIMIT $${params.length - 1} OFFSET $${params.length}`, params, db);
  return rows;
}

const lowStock = async (db) => (await query('SELECT * FROM v_low_stock', [], db)).rows;
const valuation = async (db) => (await query(
  `SELECT l.name AS location, SUM(v.stock_value)::NUMERIC(12,2) AS value, SUM(v.on_hand)::INT AS units
     FROM v_stock_valuation v JOIN locations l ON l.id = v.location_id GROUP BY l.name ORDER BY l.name`, [], db)).rows;
/** Should always be empty. Anything here means the cache drifted from the ledger. */
const integrityCheck = async (db) => (await query('SELECT * FROM v_stock_integrity_check', [], db)).rows;

// ---------------------------------------------------------------- adjustments
const REASON_TO_TYPE = { damaged: 'damage' };

async function adjust({ location_id, reason, notes, items, user_id }, db) {
  if (!items || !items.length) throw new AppError('Add at least one item', 400);
  return inTx(db, async (c) => {
    const { rows: [adj] } = await query(
      `INSERT INTO stock_adjustments (location_id, reason, notes, created_by) VALUES ($1,$2,$3,$4) RETURNING *`,
      [location_id, reason, notes || null, user_id || null], c);

    for (const it of items) {
      const { rows: [prod] } = await query('SELECT name, cost_price, requires_imei FROM products WHERE id = $1', [it.product_id], c);
      if (!prod) throw notFound('Product');
      if (prod.requires_imei) {
        // IMEI products change by device: list the IMEIs being added (+) or removed (-).
        const list = units.normalise(it.imeis || []);
        units.expectCount(list, Math.abs(it.quantity_change), prod.name);
        if (it.quantity_change > 0) await units.registerUnits(c, { product_id: it.product_id, location_id, imeis: list, unit_cost: prod.cost_price, user_id });
        else await units.removeUnits(c, { product_id: it.product_id, location_id, imeis: list, status: reason === 'damaged' ? 'defective' : 'lost' });
      }
      const slices = await expandToBatches(c, { product_id: it.product_id, location_id, quantity: it.quantity_change, batch_id: it.batch_id });
      for (const s of slices) {
        await query(
          `INSERT INTO stock_adjustment_items (stock_adjustment_id, product_id, batch_id, quantity_change) VALUES ($1,$2,$3,$4)`,
          [adj.id, it.product_id, s.batch_id, s.quantity], c);
        await applyMovement(c, {
          product_id: it.product_id, batch_id: s.batch_id, location_id, quantity: s.quantity,
          movement_type: s.quantity < 0 ? (REASON_TO_TYPE[reason] || 'adjustment') : 'adjustment',
          unit_cost: prod.cost_price, source_type: 'adjustment', source_id: adj.id, note: notes, created_by: user_id,
        });
      }
    }
    return adj;
  });
}

// ---------------------------------------------------------------- transfers
async function transfer({ from_location_id, to_location_id, notes, items, user_id }, db) {
  if (!items || !items.length) throw new AppError('Add at least one item', 400);
  return inTx(db, async (c) => {
    const { rows: [t] } = await query(
      `INSERT INTO stock_transfers (from_location_id, to_location_id, notes, created_by) VALUES ($1,$2,$3,$4) RETURNING *`,
      [from_location_id, to_location_id, notes || null, user_id || null], c);

    for (const it of items) {
      if (!(it.quantity > 0)) throw new AppError('Transfer quantity must be positive', 400);
      const { rows: [tp] } = await query('SELECT name, requires_imei FROM products WHERE id = $1', [it.product_id], c);
      if (!tp) throw notFound('Product');
      if (tp.requires_imei) {
        const list = units.normalise(it.imeis || []);
        units.expectCount(list, it.quantity, tp.name);
        await units.moveUnits(c, { product_id: it.product_id, from_location_id, to_location_id, imeis: list });
      }
      // Take from the source, then mirror the same movement at the destination.
      const outSlices = await expandToBatches(c, { product_id: it.product_id, location_id: from_location_id, quantity: -it.quantity, batch_id: it.batch_id });
      const { rows: [prod] } = await query('SELECT cost_price FROM products WHERE id = $1', [it.product_id], c);
      for (const s of outSlices) {
        await query(`INSERT INTO stock_transfer_items (stock_transfer_id, product_id, batch_id, quantity) VALUES ($1,$2,$3,$4)`,
          [t.id, it.product_id, s.batch_id, -s.quantity], c);
        const base = { product_id: it.product_id, batch_id: s.batch_id, unit_cost: prod.cost_price, source_type: 'transfer', source_id: t.id, created_by: user_id };
        await applyMovement(c, { ...base, location_id: from_location_id, quantity: s.quantity, movement_type: 'transfer_out' });
        await applyMovement(c, { ...base, location_id: to_location_id, quantity: -s.quantity, movement_type: 'transfer_in' });
      }
    }
    return t;
  });
}

// ---------------------------------------------------------------- stock takes
/** Snapshot system quantities so staff can count against them. */
async function startStockTake({ location_id, notes, user_id }, db) {
  return inTx(db, async (c) => {
    const { rows: [st] } = await query(
      `INSERT INTO stock_takes (location_id, notes, started_by) VALUES ($1,$2,$3) RETURNING *`, [location_id, notes || null, user_id || null], c);
    await query(
      `INSERT INTO stock_take_items (stock_take_id, product_id, batch_id, system_qty)
       SELECT $1::int, p.id, NULL::int, COALESCE(sl.on_hand, 0)
         FROM products p LEFT JOIN stock_levels sl ON sl.product_id = p.id AND sl.location_id = $2
        WHERE p.is_active AND NOT p.requires_imei`, [st.id, location_id], c);
    return st;
  });
}

async function getStockTake(id, db) {
  const { rows: [st] } = await query('SELECT * FROM stock_takes WHERE id = $1', [id], db);
  if (!st) throw notFound('Stock take');
  const { rows: items } = await query(
    `SELECT i.*, p.name AS product_name, p.sku
       FROM stock_take_items i JOIN products p ON p.id = i.product_id
      WHERE i.stock_take_id = $1 ORDER BY p.name`, [id], db);
  return { ...st, items };
}

async function recordCount(stock_take_id, item_id, counted_qty, db) {
  const { rows: [row] } = await query(
    `UPDATE stock_take_items i SET counted_qty = $3
       FROM stock_takes s
      WHERE i.id = $2 AND i.stock_take_id = $1 AND s.id = i.stock_take_id AND s.status = 'in_progress'
      RETURNING i.*`, [stock_take_id, item_id, counted_qty], db);
  if (!row) throw new AppError('Count item not found or stock take is closed', 404, 'NOT_FOUND');
  return row;
}

/** Apply each counted variance as a 'stock_take' ledger movement, then close the count. */
async function completeStockTake(id, user_id, db) {
  return inTx(db, async (c) => {
    const { rows: [st] } = await query(`SELECT * FROM stock_takes WHERE id = $1 FOR UPDATE`, [id], c);
    if (!st) throw notFound('Stock take');
    if (st.status !== 'in_progress') throw new AppError('Stock take is already closed', 409, 'ALREADY_CLOSED');

    const { rows: items } = await query(
      `SELECT i.*, p.cost_price FROM stock_take_items i JOIN products p ON p.id = i.product_id
        WHERE i.stock_take_id = $1 AND i.counted_qty IS NOT NULL AND i.counted_qty <> i.system_qty`, [id], c);
    for (const it of items) {
      await applyMovement(c, {
        product_id: it.product_id, batch_id: it.batch_id, location_id: st.location_id, quantity: it.variance,
        movement_type: 'stock_take', unit_cost: it.cost_price, source_type: 'stock_take', source_id: id,
        note: 'Stock count variance', created_by: user_id,
      });
    }
    await query(`UPDATE stock_takes SET status = 'completed', completed_at = NOW() WHERE id = $1`, [id], c);
    return { ...st, status: 'completed', adjusted_items: items.length };
  });
}

module.exports = {
  applyMovement, expandToBatches,
  getLevels, listMovements, lowStock, valuation, integrityCheck,
  adjust, transfer, startStockTake, getStockTake, recordCount, completeStockTake,
};
