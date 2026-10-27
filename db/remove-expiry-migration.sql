-- Phones don't expire, so the app no longer uses batches / expiry dates.
-- Run once against your existing database:  psql "$DATABASE_URL" -f db/remove-expiry-migration.sql
-- (The batch tables and batch_id columns are left in place so any history stays intact; nothing writes to them any more.)

BEGIN;

-- no product may be flagged as expiry-tracked (that flag used to force a batch on every stock movement)
UPDATE products SET tracks_expiry = FALSE WHERE tracks_expiry;

-- old "expiring soon" alerts are meaningless now
DELETE FROM notifications WHERE type = 'expiry';

-- the view the old expiry alerts and dashboard card read from
DROP VIEW IF EXISTS v_expiring_batches;

COMMIT;
