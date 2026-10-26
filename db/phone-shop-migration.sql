-- mohaaa_gadgets: phone & accessories shop additions.
-- Run ONCE (it is safe to re-run) against the existing database, e.g.:
--   psql "$DATABASE_URL" -f db/phone-shop-migration.sql

-- 1. Products: phones are tracked per IMEI/serial; any product can carry a warranty.
ALTER TABLE products ADD COLUMN IF NOT EXISTS requires_imei BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS warranty_months INT NOT NULL DEFAULT 0;

-- 2. One row per physical device (IMEI / serial number).
CREATE TABLE IF NOT EXISTS product_units (
  id           BIGSERIAL PRIMARY KEY,
  product_id   INT NOT NULL REFERENCES products(id),
  imei         VARCHAR(40) NOT NULL,
  location_id  INT REFERENCES locations(id),
  status       VARCHAR(24) NOT NULL DEFAULT 'in_stock'
               CHECK (status IN ('in_stock', 'sold', 'defective', 'lost', 'supplier_return')),
  unit_cost    NUMERIC(12,2),
  supplier_id  INT,
  grn_id       INT,
  sale_item_id BIGINT,
  received_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sold_at      TIMESTAMPTZ,
  created_by   INT,
  CONSTRAINT uq_product_units_imei UNIQUE (imei)
);
CREATE INDEX IF NOT EXISTS idx_product_units_product ON product_units (product_id, status, location_id);
CREATE INDEX IF NOT EXISTS idx_product_units_sale_item ON product_units (sale_item_id);

-- 3. Sale lines remember which devices were sold and how long the warranty runs.
ALTER TABLE sale_items ADD COLUMN IF NOT EXISTS imeis TEXT[];
ALTER TABLE sale_items ADD COLUMN IF NOT EXISTS warranty_months INT NOT NULL DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN IF NOT EXISTS warranty_expires DATE;
