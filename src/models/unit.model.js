const { query } = require('../config/db');
const { AppError } = require('../utils/errors');

/**
 * DEVICES (IMEI / serial numbers).
 * Products with requires_imei = TRUE keep their normal stock quantity in the ledger AND one product_units row per
 * physical device. Every code path that moves quantity for such a product must move the matching units too,
 * so the two never drift apart (sales, returns, voids, GRN, adjustments, transfers, supplier returns).
 */

const IMEI_RE = /^[A-Z0-9][A-Z0-9\-/]{4,39}$/;

/** Accepts an array or a text blob (commas / spaces / new lines) and returns an array of raw strings, or undefined if blank. */
function toList(x) {
  if (x === undefined || x === null || x === '') return undefined;
  if (Array.isArray(x)) return x;
  return String(x).split(/[\s,;]+/).filter(Boolean);
}

/** Trim, upper-case, validate, reject duplicates. */
function normalise(list) {
  if (!Array.isArray(list)) return [];
  const out = []; const seen = new Set();
  for (const raw of list) {
    const s = String(raw == null ? '' : raw).replace(/\s+/g, '').toUpperCase();
    if (!s) continue;
    if (!IMEI_RE.test(s)) throw new AppError(`"${raw}" is not a valid IMEI / serial number`, 422, 'INVALID_IMEI');
    if (seen.has(s)) throw new AppError(`IMEI ${s} is listed more than once`, 422, 'DUPLICATE_IMEI');
    seen.add(s); out.push(s);
  }
  return out;
}

function expectCount(list, qty, name) {
  if (list.length !== qty) {
    throw new AppError(`"${name}" is tracked by IMEI: enter exactly ${qty} IMEI / serial number(s) (you entered ${list.length})`, 422, 'IMEI_REQUIRED');
  }
}

/** Add devices to stock (new, or coming back e.g. a trade-in). The caller records the matching stock movement. */
async function registerUnits(c, { product_id, location_id, imeis, unit_cost, supplier_id, grn_id, user_id }) {
  for (const imei of imeis) {
    const { rows: [ex] } = await query('SELECT id, product_id, status FROM product_units WHERE imei = $1 FOR UPDATE', [imei], c);
    if (!ex) {
      await query(
        `INSERT INTO product_units (product_id, imei, location_id, status, unit_cost, supplier_id, grn_id, created_by)
         VALUES ($1,$2,$3,'in_stock',$4,$5,$6,$7)`,
        [product_id, imei, location_id, unit_cost ?? null, supplier_id || null, grn_id || null, user_id || null], c);
      continue;
    }
    if (ex.status === 'in_stock') throw new AppError(`IMEI ${imei} is already in stock`, 409, 'DUPLICATE_IMEI');
    if (ex.product_id !== product_id) throw new AppError(`IMEI ${imei} is registered under a different product`, 409, 'IMEI_OTHER_PRODUCT');
    await query(
      `UPDATE product_units SET status = 'in_stock', location_id = $2, sale_item_id = NULL, sold_at = NULL, unit_cost = $3,
              supplier_id = $4, grn_id = $5, received_at = NOW(), created_by = $6 WHERE id = $1`,
      [ex.id, location_id, unit_cost ?? null, supplier_id || null, grn_id || null, user_id || null], c);
  }
}

/** In-stock devices at a location leave stock with a new status (defective / lost / supplier_return). */
async function removeUnits(c, { product_id, location_id, imeis, status }) {
  const { rows } = await query(
    `UPDATE product_units SET status = $4::varchar WHERE product_id = $1 AND location_id = $2 AND status = 'in_stock'
        AND imei = ANY($3::text[]) RETURNING imei`, [product_id, location_id, imeis, status], c);
  assertAll(rows, imeis);
}

async function moveUnits(c, { product_id, from_location_id, to_location_id, imeis }) {
  const { rows } = await query(
    `UPDATE product_units SET location_id = $3 WHERE product_id = $1 AND location_id = $2 AND status = 'in_stock'
        AND imei = ANY($4::text[]) RETURNING imei`, [product_id, from_location_id, to_location_id, imeis], c);
  assertAll(rows, imeis);
}

async function takeForSale(c, { product_id, location_id, imeis, sale_item_id }) {
  const { rows } = await query(
    `UPDATE product_units SET status = 'sold', sale_item_id = $4, sold_at = NOW()
      WHERE product_id = $1 AND location_id = $2 AND status = 'in_stock' AND imei = ANY($3::text[]) RETURNING imei`,
    [product_id, location_id, imeis, sale_item_id], c);
  assertAll(rows, imeis);
}

/** Voided sale: every device on it goes back on the shelf. */
async function releaseSale(c, sale_id) {
  await query(
    `UPDATE product_units SET status = 'in_stock', sale_item_id = NULL, sold_at = NULL
      WHERE status = 'sold' AND sale_item_id IN (SELECT id FROM sale_items WHERE sale_id = $1)`, [sale_id], c);
}

/** Customer return of devices from one sale line. Without `imeis` the oldest still-sold devices on the line are used. */
async function returnUnits(c, { sale_item_id, quantity, imeis, restock, location_id }) {
  let list = imeis;
  if (!list || !list.length) {
    const { rows } = await query(
      `SELECT imei FROM product_units WHERE sale_item_id = $1 AND status = 'sold' ORDER BY id LIMIT $2`, [sale_item_id, quantity], c);
    list = rows.map((r) => r.imei);
  }
  if (list.length !== quantity) {
    throw new AppError(`Choose exactly ${quantity} IMEI / serial number(s) to return for this item`, 422, 'IMEI_REQUIRED');
  }
  const { rows } = await query(
    `UPDATE product_units SET status = $3::varchar, location_id = CASE WHEN $3::varchar = 'in_stock' THEN $4::int ELSE location_id END,
            sale_item_id = NULL, sold_at = NULL
      WHERE sale_item_id = $1 AND status = 'sold' AND imei = ANY($2::text[]) RETURNING imei`,
    [sale_item_id, list, restock ? 'in_stock' : 'defective', location_id], c);
  if (rows.length !== list.length) {
    const got = new Set(rows.map((r) => r.imei));
    throw new AppError(`IMEI ${list.filter((i) => !got.has(i)).join(', ')} was not sold on this line (or was already returned)`, 422, 'IMEI_NOT_ON_SALE');
  }
}

function assertAll(rows, imeis) {
  if (rows.length === imeis.length) return;
  const got = new Set(rows.map((r) => r.imei));
  const missing = imeis.filter((i) => !got.has(i));
  throw new AppError(`IMEI ${missing.join(', ')} is not in stock at this location for this product`, 409, 'IMEI_UNAVAILABLE', { missing });
}

const DETAIL_SQL = `
  SELECT u.id, u.imei, u.status, u.product_id, u.location_id, u.unit_cost, u.received_at, u.sold_at,
         p.name AS product_name, p.sku, l.name AS location,
         si.sale_id, si.warranty_months, si.warranty_expires, s.sale_number,
         c.full_name AS customer_name, c.phone AS customer_phone,
         CASE WHEN si.warranty_expires IS NULL THEN NULL ELSE si.warranty_expires >= CURRENT_DATE END AS under_warranty
    FROM product_units u
    JOIN products p ON p.id = u.product_id
    LEFT JOIN locations l ON l.id = u.location_id
    LEFT JOIN sale_items si ON si.id = u.sale_item_id
    LEFT JOIN sales s ON s.id = si.sale_id
    LEFT JOIN customers c ON c.id = s.customer_id`;

/** Device register / warranty look-up. q matches IMEI, product, customer name/phone or receipt number. */
async function search({ q, status, product_id, location_id, limit = 50, offset = 0 } = {}, db) {
  const where = []; const params = [];
  if (status) { params.push(status); where.push(`u.status = $${params.length}`); }
  if (product_id) { params.push(product_id); where.push(`u.product_id = $${params.length}`); }
  if (location_id) { params.push(location_id); where.push(`u.location_id = $${params.length}`); }
  if (q) {
    params.push(`%${q}%`);
    const n = params.length;
    where.push(`(u.imei ILIKE $${n} OR p.name ILIKE $${n} OR p.sku ILIKE $${n} OR c.full_name ILIKE $${n} OR c.phone ILIKE $${n} OR s.sale_number ILIKE $${n})`);
  }
  params.push(limit, offset);
  const { rows } = await query(
    `SELECT t.*, COUNT(*) OVER()::INT AS total_count FROM (${DETAIL_SQL} ${where.length ? 'WHERE ' + where.join(' AND ') : ''}) t
      ORDER BY t.id DESC LIMIT $${params.length - 1} OFFSET $${params.length}`, params, db);
  return { items: rows.map(({ total_count, ...r }) => r), total: rows[0] ? rows[0].total_count : 0 };
}

async function getByImei(imei, db) {
  const { rows: [r] } = await query(`${DETAIL_SQL} WHERE u.imei = $1`, [imei], db);
  return r || null;
}

module.exports = { toList, normalise, expectCount, registerUnits, removeUnits, moveUnits, takeForSale, releaseSale, returnUnits, search, getByImei };
