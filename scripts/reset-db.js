#!/usr/bin/env node
/**
 * RESET THE DATABASE (destructive) and create the real login accounts.
 *
 *   node scripts/reset-db.js                    # asks you to type the database name to confirm
 *   node scripts/reset-db.js --confirm=<dbname> # non-interactive (CI / deploy scripts)
 *
 * What it does:
 *   1. Validates the user list FIRST (so a typo never leaves you with a wiped, empty database).
 *   2. DROP SCHEMA public CASCADE, then re-creates it from db/schema.sql
 *      (roles, permissions, tax rates, locations, categories and brands are seeded by that file).
 *   3. Creates the accounts from scripts/users.production.json (see users.production.example.json),
 *      or, if that file is missing, a single admin from ADMIN_EMAIL / ADMIN_NAME / ADMIN_PASSWORD.
 *      Users without a "password" get a strong random one, printed once.
 *
 * Options:
 *   --users=<file>   use a different users JSON file
 *   --no-users       reset only; create the admin later via the app's /setup screen
 *   --confirm=<db>   skip the typed confirmation (must equal the database name)
 */
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { dbInfo, connect } = require('./lib/env');
const { validateUsers, createUsers, printCredentials, generatePassword } = require('./lib/users');

const args = Object.fromEntries(process.argv.slice(2).map((a) => {
  const [k, ...v] = a.replace(/^--/, '').split('=');
  return [k, v.length ? v.join('=') : true];
}));

function loadUsers() {
  if (args['no-users']) return null;
  const file = path.resolve(typeof args.users === 'string' ? args.users : path.join(__dirname, 'users.production.json'));
  if (fs.existsSync(file)) {
    try { return { source: file, list: JSON.parse(fs.readFileSync(file, 'utf8')) }; }
    catch (e) { throw new Error(`Could not read ${file}: ${e.message}`); }
  }
  if (typeof args.users === 'string') throw new Error(`Users file not found: ${file}`);
  if (process.env.ADMIN_EMAIL) {
    return { source: 'ADMIN_* environment variables', list: [{
      name: process.env.ADMIN_NAME || 'Administrator', email: process.env.ADMIN_EMAIL, role: 'admin',
      password: process.env.ADMIN_PASSWORD || undefined }] };
  }
  throw new Error(
    'No users defined. Either:\n' +
    '  - copy scripts/users.production.example.json to scripts/users.production.json and edit it, or\n' +
    '  - set ADMIN_EMAIL (and optionally ADMIN_NAME / ADMIN_PASSWORD) in the environment, or\n' +
    '  - run with --no-users and create the admin from the app\'s first-time setup screen.');
}

const ask = (q) => new Promise((resolve) => {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  rl.question(q, (a) => { rl.close(); resolve(a.trim()); });
});

(async () => {
  const db = dbInfo();
  const users = loadUsers();
  if (users) validateUsers(users.list); // fail BEFORE wiping anything

  const schemaFile = path.join(__dirname, '..', 'db', 'schema.sql');
  const schemaSql = fs.readFileSync(schemaFile, 'utf8');

  console.log('\n  !!  THIS WILL DELETE EVERY TABLE AND ALL DATA  !!');
  console.log(`      Host:     ${db.host || '(local socket)'}${db.isLocal ? '' : '   <-- NOT localhost'}`);
  console.log(`      Database: ${db.name}`);
  console.log(`      NODE_ENV: ${process.env.NODE_ENV || '(not set)'}`);
  if (users) console.log(`      Users:    ${users.list.length} from ${users.source}`);

  if (args.confirm !== undefined) {
    if (args.confirm !== db.name) { console.error(`\n--confirm must equal the database name ("${db.name}"). Nothing was changed.`); process.exit(1); }
  } else {
    if (!process.stdin.isTTY) { console.error('\nNot an interactive terminal: pass --confirm=' + db.name); process.exit(1); }
    const typed = await ask(`\n  Type the database name (${db.name}) to continue: `);
    if (typed !== db.name) { console.log('  Cancelled. Nothing was changed.'); process.exit(1); }
  }

  const client = await connect();
  try {
    console.log('\n  Dropping schema...');
    await client.query('DROP SCHEMA IF EXISTS public CASCADE');
    await client.query('CREATE SCHEMA public');
    await client.query('GRANT ALL ON SCHEMA public TO CURRENT_USER');
    await client.query('GRANT USAGE ON SCHEMA public TO PUBLIC');

    console.log('  Applying db/schema.sql ...');
    await client.query('BEGIN');
    await client.query(schemaSql);
    await client.query('COMMIT');

    const { rows: [c] } = await client.query(
      `SELECT (SELECT COUNT(*) FROM roles) AS roles, (SELECT COUNT(*) FROM permissions) AS perms,
              (SELECT COUNT(*) FROM categories) AS cats, (SELECT COUNT(*) FROM brands) AS brands`);
    console.log(`  Schema ready: ${c.roles} roles, ${c.perms} permissions, ${c.cats} categories, ${c.brands} brands.`);

    if (users) {
      console.log('  Creating accounts...');
      const rows = await createUsers(client, users.list);
      printCredentials(rows);
    } else {
      console.log('\n  No users created. Open the app and use the first-time setup screen to make the admin.');
    }
    console.log('\n  Done.\n');
  } catch (e) {
    try { await client.query('ROLLBACK'); } catch (_) { /* nothing open */ }
    console.error('\n  FAILED:', e.message);
    if (e.position) console.error('  (SQL error near character ' + e.position + ' of schema.sql)');
    process.exitCode = 1;
  } finally {
    await client.end();
  }
})().catch((e) => { console.error('\n' + e.message); process.exit(1); });
