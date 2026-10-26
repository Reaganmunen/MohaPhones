// Shared by reset-db.js, create-users.js and seed-dev.js.
// Uses the same bcrypt cost (12) as src/services/auth.service.js so logins behave identically.
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { normalisePhone } = require('../../src/utils/phone');

const ROLES = ['admin', 'manager', 'cashier', 'stock_keeper'];
const BCRYPT_ROUNDS = 12;

/** 16 random chars, guaranteed to contain upper, lower, digit and symbol. No look-alike characters. */
function generatePassword(len = 16) {
  const sets = ['ABCDEFGHJKLMNPQRSTUVWXYZ', 'abcdefghijkmnpqrstuvwxyz', '23456789', '!@#$%&*?'];
  const all = sets.join('');
  const pick = (s) => s[crypto.randomInt(s.length)];
  const chars = sets.map(pick);
  while (chars.length < len) chars.push(pick(all));
  for (let i = chars.length - 1; i > 0; i--) { // Fisher-Yates shuffle
    const j = crypto.randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }
  return chars.join('');
}

/** Throws a readable error for anything the app itself would reject. Run BEFORE touching the database. */
function validateUsers(list) {
  if (!Array.isArray(list) || !list.length) throw new Error('No users to create.');
  const seen = new Set();
  list.forEach((u, i) => {
    const where = `User #${i + 1} (${u && u.email || 'no email'})`;
    if (!u || !u.name || !String(u.name).trim()) throw new Error(`${where}: "name" is required`);
    if (!u.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(u.email)) throw new Error(`${where}: valid "email" is required`);
    if (!ROLES.includes(u.role)) throw new Error(`${where}: "role" must be one of ${ROLES.join(', ')}`);
    if (u.password !== undefined && (typeof u.password !== 'string' || u.password.length < 8 || u.password.length > 72)) {
      throw new Error(`${where}: password must be 8-72 characters`);
    }
    if (u.phone) normalisePhone(u.phone); // throws on garbage
    const key = u.email.trim().toLowerCase();
    if (seen.has(key)) throw new Error(`${where}: email listed twice`);
    seen.add(key);
  });
  if (!list.some((u) => u.role === 'admin')) throw new Error('At least one user must have the "admin" role.');
}

/**
 * Creates users that do not exist yet (matched on lower-cased email). Existing ones are left untouched
 * unless opts.resetPasswords is true. Returns [{ email, role, password|null, status }] -
 * `password` is only set when we generated or applied one, so it can be shown ONCE.
 */
async function createUsers(client, list, opts = {}) {
  const { rows: roles } = await client.query('SELECT id, name FROM roles');
  const roleId = Object.fromEntries(roles.map((r) => [r.name, r.id]));
  const out = [];
  for (const u of list) {
    if (!roleId[u.role]) throw new Error(`Role "${u.role}" is missing from the database. Run reset-db.js first.`);
    const email = u.email.trim();
    const { rows: [existing] } = await client.query('SELECT id FROM users WHERE LOWER(email) = LOWER($1)', [email]);
    const plain = u.password || generatePassword();
    if (existing && !opts.resetPasswords) { out.push({ email, role: u.role, password: null, status: 'already exists (unchanged)' }); continue; }
    const hash = await bcrypt.hash(plain, BCRYPT_ROUNDS);
    if (existing) {
      await client.query('UPDATE users SET password_hash = $2, role_id = $3, is_active = TRUE, name = $4 WHERE id = $1',
        [existing.id, hash, roleId[u.role], u.name.trim()]);
      await client.query(`DELETE FROM user_tokens WHERE user_id = $1`, [existing.id]); // sign out old sessions
      out.push({ email, role: u.role, password: plain, status: 'password reset' });
    } else {
      await client.query('INSERT INTO users (name, email, phone, password_hash, role_id) VALUES ($1,$2,$3,$4,$5)',
        [u.name.trim(), email, u.phone ? normalisePhone(u.phone) : null, hash, roleId[u.role]]);
      out.push({ email, role: u.role, password: plain, status: u.password ? 'created' : 'created (generated password)' });
    }
  }
  return out;
}

function printCredentials(rows, { warn = true } = {}) {
  console.log('\n  ' + 'ACCOUNT'.padEnd(36) + 'ROLE'.padEnd(15) + 'PASSWORD');
  console.log('  ' + '-'.repeat(78));
  for (const r of rows) console.log(`  ${r.email.padEnd(36)}${r.role.padEnd(15)}${r.password || '(unchanged)'}`);
  if (warn && rows.some((r) => r.password)) {
    console.log('\n  Passwords are shown ONCE and are not stored anywhere in plain text.');
    console.log('  Copy them to a password manager now, and have each person change theirs after first login.');
  }
}

module.exports = { ROLES, generatePassword, validateUsers, createUsers, printCredentials };
