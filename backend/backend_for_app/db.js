const mysql = require("mysql2/promise");

// MySQL connection pool
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "1234",
  database: "flutter_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

module.exports = pool;