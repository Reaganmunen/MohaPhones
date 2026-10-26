#!/usr/bin/env node
/**
 * SEED TEST DATA + TEST LOGINS  (development / demo only)
 *
 *   node scripts/seed-dev.js                 # users + sample shop data (safe to re-run)
 *   node scripts/seed-dev.js --users-only    # just the 4 test logins
 *   node scripts/seed-dev.js --allow-remote  # needed if DATABASE_URL is not localhost
 *
 * Refuses to run when NODE_ENV=production. Run `node scripts/reset-db.js` first if you want a clean slate.
 *
 * Everything goes through the app's own models (receiveGoods, createSale, ...), so stock levels, IMEI
 * registers, loyalty points, VAT and warranty dates are exactly what the real app would produce.
 *
 * Test logins (override the shared password with SEED_PASSWORD=...):
 *   admin@mohaaa.test | manager@mohaaa.test | cashier@mohaaa.test | stock@mohaaa.test      password: Dev@12345
 */
const { dbInfo, connect } = require('./lib/env');
const { createUsers, printCredentials } = require('./lib/users');

const args = new Set(process.argv.slice(2));
const PASSWORD = process.env.SEED_PASSWORD || 'Dev@12345';

if (process.env.NODE_ENV === 'production') { console.error('Refusing to seed test data with NODE_ENV=production.'); process.exit(1); }
const db = dbInfo();
if (!db.isLocal && !args.has('--allow-remote')) {
  console.error(`DATABASE_URL points at "${db.host}", not localhost. Re-run with --allow-remote if you really mean to put test data there.`);
  process.exit(1);
}

// Deterministic pseudo-random numbers: same data every run.
let seed = 20261026;
const rnd = () => { seed |= 0; seed = (seed + 0x6D2B79F5) | 0; let t = Math.imul(seed ^ (seed >>> 15), 1 | seed); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
const randInt = (a, b) => a + Math.floor(rnd() * (b - a + 1));
const pick = (arr) => arr[Math.floor(rnd() * arr.length)];

const TEST_USERS = [
  { name: 'Test Admin',        email: 'admin@mohaaa.test',   phone: '0700000001', role: 'admin',        password: PASSWORD },
  { name: 'Test Manager',      email: 'manager@mohaaa.test', phone: '0700000002', role: 'manager',      password: PASSWORD },
  { name: 'Test Cashier',      email: 'cashier@mohaaa.test', phone: '0700000003', role: 'cashier',      password: PASSWORD },
  { name: 'Test Stock Keeper', email: 'stock@mohaaa.test',   phone: '0700000004', role: 'stock_keeper', password: PASSWORD },
];

const SUPPLIERS = [
  { name: 'Nairobi Mobile Distributors', contact_person: 'James Kariuki', phone: '0711000111', email: 'sales@nmd.test', address: 'Luthuli Avenue, Nairobi', payment_terms: '14 days' },
  { name: 'Gadget Hub Wholesalers',      contact_person: 'Amina Hassan',  phone: '0722000222', email: 'orders@gadgethub.test', address: 'Moi Avenue, Nairobi', payment_terms: 'Cash on delivery' },
  { name: 'Oraimo Kenya (Authorised)',   contact_person: 'Peter Otieno',  phone: '0733000333', email: 'b2b@oraimo.test', address: 'Westlands, Nairobi', payment_terms: '30 days' },
];

const CUSTOMERS = [
  { full_name: 'Wanjiru Mwangi', phone: '0712345601' },
  { full_name: 'Brian Otieno',   phone: '0723456702' },
  { full_name: 'Fatuma Ali',     phone: '0734567803' },
  { full_name: 'Kevin Kiprop',   phone: '0745678904' },
  { full_name: 'Grace Njeri',    phone: '0756789005', email: 'grace@example.test' },
  { full_name: 'Lakeview Cyber Cafe', customer_type: 'business', organization_name: 'Lakeview Cyber Cafe', phone: '0767890106', credit_limit: 50000 },
  { full_name: 'Samuel Mutua',   phone: '0778901207', credit_limit: 20000 },
];

// sell = VAT-inclusive shelf price, cost = ex-VAT buying price.  supplier index refers to SUPPLIERS.
const PRODUCTS = [
  { sku: 'DEV-PH-001', name: 'Samsung Galaxy A15 128GB',  cat: 'Smartphones', brand: 'Samsung', cost: 15500, sell: 18999, min: 17500, phone: true, qty: 10, sup: 0, reorder: 3 },
  { sku: 'DEV-PH-002', name: 'Tecno Spark 20 128GB',      cat: 'Smartphones', brand: 'Tecno',   cost: 11000, sell: 13499, min: 12500, phone: true, qty: 12, sup: 0, reorder: 3 },
  { sku: 'DEV-PH-003', name: 'Infinix Hot 40i 128GB',     cat: 'Smartphones', brand: 'Infinix', cost: 10500, sell: 12999, min: 12000, phone: true, qty: 9,  sup: 1, reorder: 3 },
  { sku: 'DEV-PH-004', name: 'Redmi 13C 128GB',           cat: 'Smartphones', brand: 'Redmi',   cost: 11500, sell: 13999, min: 13000, phone: true, qty: 8,  sup: 1, reorder: 3 },
  { sku: 'DEV-PH-005', name: 'iPhone 13 128GB (Refurb)',  cat: 'Smartphones', brand: 'Apple',   cost: 62000, sell: 74999, min: 70000, phone: true, qty: 2,  sup: 1, reorder: 3 }, // deliberately LOW stock
  { sku: 'DEV-PH-006', name: 'itel A60s 64GB',            cat: 'Smartphones', brand: 'itel',    cost: 6500,  sell: 7999,  min: 7500,  phone: true, qty: 14, sup: 0, reorder: 4 },
  { sku: 'DEV-AC-001', name: 'Oraimo 20W Fast Charger',   cat: 'Chargers & Cables', brand: 'Oraimo', cost: 600,  sell: 999,  min: 850,  warranty: 6, qty: 40, sup: 2, reorder: 10 },
  { sku: 'DEV-AC-002', name: 'Oraimo Power Bank 10000mAh', cat: 'Power Banks', brand: 'Oraimo', cost: 1400, sell: 2199, min: 1900, warranty: 6, qty: 25, sup: 2, reorder: 8 },
  { sku: 'DEV-AC-003', name: 'Anker USB-C Cable 1m',      cat: 'Chargers & Cables', brand: 'Anker', cost: 500, sell: 899,  min: 750,  warranty: 12, qty: 35, sup: 1, reorder: 10 },
  { sku: 'DEV-AC-004', name: 'JBL Tune 110 Earphones',    cat: 'Earphones & Headphones', brand: 'JBL', cost: 1800, sell: 2799, min: 2400, warranty: 6, qty: 15, sup: 1, reorder: 5 },
  { sku: 'DEV-AC-005', name: 'Tempered Glass Screen Protector', cat: 'Screen Protectors', brand: 'Generic', cost: 60, sell: 250, min: 150, qty: 120, sup: 1, reorder: 30 },
  { sku: 'DEV-AC-006', name: 'Silicone Phone Case (assorted)', cat: 'Phone Cases & Covers', brand: 'Generic', cost: 150, sell: 500, min: 300, qty: 80, sup: 1, reorder: 20 },
  { sku: 'DEV-AC-007', name: 'SanDisk 64GB microSD',      cat: 'Memory Cards & Storage', brand: 'Generic', cost: 550, sell: 950, min: 800, warranty: 12, qty: 4, sup: 1, reorder: 6 }, // LOW stock
];

const EXPENSES = [
  ['Rent', 45000, 'bank_transfer', 'Shop rent - this month', 12], ['Utilities', 3800, 'mpesa', 'KPLC tokens', 9],
  ['Airtime & Internet', 2500, 'mpesa', 'Safaricom fibre', 8], ['Transport', 1200, 'cash', 'Boda boda - supplier pickup', 6],
  ['Marketing', 3000, 'mpesa', 'Instagram ads', 5], ['Supplies', 850, 'cash', 'Receipt rolls & packaging', 3],
  ['Salaries', 30000, 'bank_transfer', 'Cashier salary', 2], ['Repairs & Maintenance', 1500, 'cash', 'Display shelf fix', 1],
];

let imeiCounter = 0;
const nextImei = () => '35' + String(100000000000 + (++imeiCounter) * 7919).padStart(13, '0').slice(-13); // 15 digits, unique

async function main() {
  const client = await connect();
  try {
    const { rows: [r] } = await client.query("SELECT COUNT(*)::int AS n FROM roles");
    if (!r.n) throw new Error('The database has no roles. Run `node scripts/reset-db.js` first to create the schema.');

    // 1. test logins -------------------------------------------------------------------------
    const userRows = await createUsers(client, TEST_USERS, { resetPasswords: true });
    printCredentials(userRows.map((u) => ({ ...u, password: PASSWORD })), { warn: false });
    if (args.has('--users-only')) return;

    // Models share one pool (src/config/db) - require them only now that .env is loaded.
    const models = require('../src/models');
    const { query } = require('../src/config/db');
    const id = async (sql, p) => (await client.query(sql, p)).rows[0].id;
    const admin = await id("SELECT id FROM users WHERE email = 'admin@mohaaa.test'");
    const manager = await id("SELECT id FROM users WHERE email = 'manager@mohaaa.test'");
    const cashier = await id("SELECT id FROM users WHERE email = 'cashier@mohaaa.test'");

    const { rows: [already] } = await client.query("SELECT 1 FROM products WHERE sku LIKE 'DEV-%' LIMIT 1");
    if (already) { console.log('\n  Sample shop data already present: skipping (run reset-db.js for a clean slate).\n'); return; }

    const shopFloor = await id("SELECT id FROM locations WHERE is_default AND is_active LIMIT 1");
    const storeRoom = await id("SELECT id FROM locations WHERE type = 'store_room' LIMIT 1");
    const unitPc = await id("SELECT id FROM units WHERE abbreviation = 'pc'");

    // 2. suppliers, customers ----------------------------------------------------------------
    console.log('\n  Seeding suppliers, customers, products...');
    const suppliers = [];
    for (const s of SUPPLIERS) suppliers.push(await models.suppliers.create(s));
    const customers = [];
    for (const c of CUSTOMERS) customers.push(await models.customers.create({ ...c, created_by: admin }));

    // 3. products + stock received through goods-received notes -------------------------------
    const products = [];
    for (const p of PRODUCTS) {
      const row = await models.products.create({
        sku: p.sku, name: p.name, unit_id: unitPc,
        category_id: await id('SELECT id FROM categories WHERE name = $1', [p.cat]),
        brand_id: await id('SELECT id FROM brands WHERE name = $1', [p.brand]),
        cost_price: p.cost, selling_price: p.sell, min_price: p.min, reorder_level: p.reorder, reorder_qty: p.reorder * 3,
        requires_imei: !!p.phone, warranty_months: p.phone ? 12 : (p.warranty || 0), created_by: admin,
      });
      products.push({ ...p, id: row.id });
    }
    for (let si = 0; si < suppliers.length; si++) {
      const lines = products.filter((p) => p.sup === si);
      if (!lines.length) continue;
      await models.purchases.receiveGoods({
        supplier_id: suppliers[si].id, location_id: shopFloor, supplier_invoice_no: `INV-DEV-${100 + si}`,
        received_date: new Date(Date.now() - 16 * 864e5).toISOString().slice(0, 10), notes: 'Sample opening delivery', received_by: manager,
        items: lines.map((p) => ({ product_id: p.id, quantity: p.qty, unit_cost: p.cost, ...(p.phone ? { imeis: Array.from({ length: p.qty }, nextImei) } : {}) })),
      });
    }
    // Move a few accessories to the store room so transfers/locations have something to show.
    await models.stock.transfer({ from_location_id: shopFloor, to_location_id: storeRoom, notes: 'Back-stock', user_id: manager,
      items: products.filter((p) => ['DEV-AC-005', 'DEV-AC-006'].includes(p.sku)).map((p) => ({ product_id: p.id, quantity: 40 })) });

    // A purchase order still waiting for delivery.
    await models.purchases.createPO({ supplier_id: suppliers[0].id, status: 'ordered', created_by: manager, notes: 'Restock Samsung & itel',
      expected_date: new Date(Date.now() + 3 * 864e5).toISOString().slice(0, 10),
      items: [{ product_id: products[0].id, quantity: 10, unit_cost: 15500, tax_rate: 16 }, { product_id: products[5].id, quantity: 10, unit_cost: 6500, tax_rate: 16 }] });

    // 4. sales spread over the last 14 days ---------------------------------------------------
    console.log('  Seeding sales...');
    const sellable = products.filter((p) => p.sku !== 'DEV-PH-005' && p.sku !== 'DEV-AC-007'); // keep the low-stock items low
    let made = 0;
    const { rows: lv } = await client.query('SELECT product_id, on_hand FROM stock_levels WHERE location_id = $1', [shopFloor]);
    const remaining = new Map(lv.map((x) => [x.product_id, x.on_hand])); // what the shop floor can still sell
    for (let n = 0; n < 40; n++) {
      const daysAgo = Math.floor((39 - n) / 40 * 14);
      const when = new Date(Date.now() - daysAgo * 864e5 - randInt(0, 8) * 36e5);
      const lineCount = randInt(1, 3);
      const chosen = new Set();
      const items = [];
      for (let i = 0; i < lineCount; i++) {
        const p = pick(sellable); if (chosen.has(p.id)) continue; chosen.add(p.id);
        const qty = Math.min(p.phone ? 1 : randInt(1, 3), remaining.get(p.id) || 0);
        if (qty < 1) continue;
        const item = { product_id: p.id, quantity: qty };
        if (p.phone) {
          const { rows } = await client.query(
            "SELECT imei FROM product_units WHERE product_id = $1 AND status = 'in_stock' AND location_id = $2 ORDER BY id LIMIT $3", [p.id, shopFloor, qty]);
          if (rows.length < qty) continue;
          item.imeis = rows.map((x) => x.imei);
        }
        item.price = p.sell * qty; items.push(item);
      }
      if (!items.length) continue;
      const total = items.reduce((s, i) => s + i.price, 0);
      const useCustomer = rnd() < 0.5 ? pick(customers) : null;
      const creditSale = useCustomer && useCustomer.credit_limit > 0 && total < 15000 && rnd() < 0.5;
      const method = pick(['cash', 'cash', 'mpesa', 'mpesa', 'card']);
      const payments = creditSale
        ? [{ method: 'mpesa', amount: Math.round(total / 2), reference: 'SEED' + randInt(1000000, 9999999) }]   // rest stays on credit
        : [{ method, amount: total, ...(method !== 'cash' ? { reference: 'SEED' + randInt(1000000, 9999999) } : {}) }];
      try {
        const sale = await models.sales.createSale({
          customer_id: useCustomer ? useCustomer.id : null, sold_by: cashier, location_id: shopFloor,
          items: items.map(({ price, ...rest }) => rest), payments,
        });
        // Back-date so dashboards and reports show a believable trend. (stock_movements is append-only, so it keeps today's date.)
        await client.query('UPDATE sales SET sold_at = $2, created_at = $2 WHERE id = $1', [sale.id, when]);
        await client.query('UPDATE payments SET paid_at = $2 WHERE sale_id = $1', [sale.id, when]);
        await client.query('UPDATE product_units SET sold_at = $2 WHERE sale_item_id IN (SELECT id FROM sale_items WHERE sale_id = $1)', [sale.id, when]);
        await client.query(`UPDATE sale_items i SET warranty_expires = CASE WHEN i.warranty_months > 0
            THEN ((s.sold_at AT TIME ZONE 'Africa/Nairobi')::date + make_interval(months => i.warranty_months))::date END
          FROM sales s WHERE s.id = i.sale_id AND i.sale_id = $1`, [sale.id]);
        for (const it of items) remaining.set(it.product_id, remaining.get(it.product_id) - it.quantity);
        made++;
      } catch (e) { console.log(`    (skipped one sale: ${e.message})`); }
    }
    console.log(`  Created ${made} sales.`);

    // 5. expenses ---------------------------------------------------------------------------
    for (const [cat, amount, method, description, daysAgo] of EXPENSES) {
      await models.expenses.create({
        category_id: await id('SELECT id FROM expense_categories WHERE name = $1', [cat]), amount, method, description,
        expense_date: new Date(Date.now() - daysAgo * 864e5).toISOString().slice(0, 10), recorded_by: admin,
      });
    }

    // 6. sanity checks -----------------------------------------------------------------------
    const { rows: bad } = await client.query('SELECT * FROM v_device_integrity_check');
    const { rows: bad2 } = await client.query('SELECT * FROM v_stock_integrity_check');
    console.log(bad.length || bad2.length ? '\n  WARNING: integrity views report mismatches.' : '  Integrity checks: stock and IMEI registers agree.');
    console.log('\n  Done. Start the app (npm start) and log in with any account above.\n');
  } finally {
    await client.end();
    try { await require('../src/config/db').pool.end(); } catch (_) { /* pool never opened */ }
  }
}

main().catch((e) => { console.error('\n  FAILED:', e.message); process.exit(1); });
