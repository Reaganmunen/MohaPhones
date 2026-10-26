# Database scripts

Drop the `scripts/` folder into the project root (next to `src/` and `db/`). They use only packages the app already
depends on (`pg`, `bcryptjs`, `dotenv`) and read `DATABASE_URL` from `.env`.

| Command | What it does | Safe on live data? |
|---|---|---|
| `node scripts/seed-dev.js` | 4 test logins + sample suppliers, customers, phones (with IMEIs), accessories, ~40 back-dated sales, expenses | Dev only: refuses `NODE_ENV=production` and non-localhost DBs |
| `node scripts/reset-db.js` | **Wipes everything**, rebuilds from `db/schema.sql`, creates the real accounts | **No - destructive**, asks you to type the DB name |
| `node scripts/create-users.js` | Adds accounts only; never touches other data | Yes |

## Test logins (seed-dev.js)
`admin@mohaaa.test`, `manager@mohaaa.test`, `cashier@mohaaa.test`, `stock@mohaaa.test` - password `Dev@12345`
(override with `SEED_PASSWORD=...`).

## Production accounts
1. `cp scripts/users.production.example.json scripts/users.production.json` and edit names/emails/roles.
   Leave `password` out to get a strong random one (printed once), or set your own (8-72 chars).
2. `node scripts/reset-db.js` (fresh install) or `node scripts/create-users.js` (existing database).
3. Add `scripts/users.production.json` to `.gitignore`.

Handy extras: `reset-db.js --no-users` (create the admin from the app's setup screen instead),
`--confirm=<dbname>` (non-interactive), `create-users.js --reset-passwords` (new password for existing listed users).

Suggested `package.json` scripts:
```json
"db:reset": "node scripts/reset-db.js",
"db:seed": "node scripts/seed-dev.js",
"db:users": "node scripts/create-users.js"
```
