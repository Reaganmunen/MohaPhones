const models = require('../models');
const v = require('../utils/validate');
const { ok, created, paged, wrap } = require('../utils/respond');
const { paginate } = require('../utils/sql');
const { AppError } = require('../utils/errors');
const audit = require('../utils/audit');

const U = () => models.devices;

/** Device register: ?q= &status= &product_id= &location_id= */
exports.list = wrap(async (req, res) => {
  const page = paginate(req.query);
  const q = req.query;
  const r = await U().search({
    q: q.q ? String(q.q).trim() : undefined,
    status: q.status ? v.oneOf(q.status, 'status', ['in_stock', 'sold', 'defective', 'lost', 'supplier_return']) : undefined,
    product_id: v.optId(q.product_id, 'product_id'), location_id: v.optId(q.location_id, 'location_id'), ...page,
  });
  paged(res, r.items, r.total, page);
});

/** POS check of one IMEI: is it a known device, and can it be sold from the selling location right now? */
exports.check = wrap(async (req, res) => {
  const [imei] = U().normalise([req.query.imei]);
  if (!imei) throw v.bad('imei is required');
  const unit = await U().getByImei(imei);
  if (!unit) throw new AppError(`IMEI ${imei} is not in the system`, 404, 'NOT_FOUND');
  const location_id = v.optId(req.query.location_id, 'location_id') || (await models.defaultLocationId());
  ok(res, { ...unit, available: unit.status === 'in_stock' && unit.location_id === location_id });
});

/** Body: { imeis: [..] | text }. Tells the add-phones screen which of the scanned IMEIs are already in the system. */
exports.validate = wrap(async (req, res) => {
  const list = U().toList((req.body || {}).imeis) || [];
  if (list.length > 500) throw v.bad('Check at most 500 IMEIs at a time');
  ok(res, await U().inspect(list));
});

/** Add devices to stock by IMEI (stock goes up by the same number). Body: { product_id, imeis[] | text, location_id?, notes? } */
exports.intake = wrap(async (req, res) => {
  const b = req.body || {};
  v.required(b, ['product_id']);
  const product_id = v.id(b.product_id, 'product_id');
  const imeis = U().normalise(U().toList(b.imeis) || []);
  if (!imeis.length) throw v.bad('Enter at least one IMEI / serial number');
  const product = await models.products.getById(product_id);
  if (!product.requires_imei) throw new AppError(`"${product.name}" is not set to track IMEI numbers. Turn that on in Products first.`, 422, 'NOT_IMEI_PRODUCT');
  const location_id = v.optId(b.location_id, 'location_id') || (await models.defaultLocationId());
  const adj = await models.stock.adjust({
    location_id, reason: 'found', notes: b.notes || 'IMEI intake', user_id: req.user.id,
    items: [{ product_id, quantity_change: imeis.length, imeis }],
  });
  await audit.record(req, 'imei_intake', 'product', product_id, null, { count: imeis.length });
  created(res, { adjustment_id: adj.id, registered: imeis.length });
});
