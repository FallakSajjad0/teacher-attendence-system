const { Pool } = require('pg');
const logger = require('../utils/logger');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000
});
const connectDatabase = async () => {
  const client = await pool.connect();
  try {
    const { rows } = await client.query('SELECT NOW() AS now');
    logger.info(`Supabase PostgreSQL connected: ${rows[0].now}`);
  } finally { client.release(); }
};
const disconnectDatabase = async () => pool.end();
module.exports = { pool, connectDatabase, disconnectDatabase };
