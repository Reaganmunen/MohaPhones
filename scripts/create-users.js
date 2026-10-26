#!/usr/bin/env node
/**
 * Add accounts WITHOUT touching any other data (safe to run on a live database).
 *
 *   node scripts/create-users.js                       # reads scripts/users.production.json
 *   node scripts/create-users.js --users=my-list.json
 *   node scripts/create-users.js --reset-passwords     # also give EXISTING listed users a new password
 *
 * Existing emails are skipped unless --reset-passwords is given. Users with no "password"
 * in the file get a random one, printed once.
 */
const fs = require('fs');
const path = require('path');
const { connect } = require('./lib/env');
const { validateUsers, createUsers, printCredentials } = require('./lib/users');

const args = Object.fromEntries(process.argv.slice(2).map((a) => { const [k, ...v] = a.replace(/^--/, '').split('='); return [k, v.length ? v.join('=') : true]; }));

(async () => {
  const file = path.resolve(typeof args.users === 'string' ? args.users : path.join(__dirname, 'users.production.json'));
  if (!fs.existsSync(file)) throw new Error(`Users file not found: ${file}\nCopy scripts/users.production.example.json to scripts/users.production.json and edit it.`);
  const list = JSON.parse(fs.readFileSync(file, 'utf8'));
  validateUsers(list);
  const client = await connect();
  try {
    await client.query('BEGIN');
    const rows = await createUsers(client, list, { resetPasswords: !!args['reset-passwords'] });
    await client.query('COMMIT');
    printCredentials(rows);
    console.log();
  } catch (e) { await client.query('ROLLBACK'); throw e; }
  finally { await client.end(); }
})().catch((e) => { console.error('\n' + e.message); process.exit(1); });
