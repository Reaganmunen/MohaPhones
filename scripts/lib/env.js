// Loads .env from the project root and returns the database connection details.
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '..', '.env') });
const { Client } = require('pg');

function dbInfo() {
  const url = process.env.DATABASE_URL;
  if (!url) { console.error('DATABASE_URL is not set (check your .env file).'); process.exit(1); }
  let u;
  try { u = new URL(url); } catch { console.error('DATABASE_URL is not a valid connection string.'); process.exit(1); }
  const host = u.hostname;
  return { url, host, name: decodeURIComponent(u.pathname.replace(/^\//, '')), isLocal: ['localhost', '127.0.0.1', '::1', ''].includes(host) };
}

async function connect() {
  const { url } = dbInfo();
  const client = new Client({ connectionString: url });
  await client.connect();
  await client.query("SET TIME ZONE 'Africa/Nairobi'");
  return client;
}

module.exports = { dbInfo, connect };
