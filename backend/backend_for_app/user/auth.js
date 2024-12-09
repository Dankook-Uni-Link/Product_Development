const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const pool = require("../db");
const router = express.Router();

const SECRET_KEY = "your_secret_key"; // 배포 환경에서는 안전하게 관리

// 회원가입
router.post("/register", async (req, res) => {
  const { username, password, email, gender, birthdate } = req.body;
  try {
    const result = await registerUser(pool, username, password, email, gender, birthdate);
    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(400).send(error.message);
  }
});

// 로그인
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await loginUser(pool, username, password);
    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(400).send(error.message);
  }
});

// 회원가입 로직
async function registerUser(pool, username, password, email, gender, birthdate) {
  const connection = await pool.getConnection();
  try {
    const [existingUser] = await connection.query(
      "SELECT * FROM users WHERE username = ? OR email = ?",
      [username, email]
    );
    if (existingUser.length > 0) {
      throw new Error("Username or email already exists");
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    await connection.query(
      "INSERT INTO users (username, password, email, gender, birthdate) VALUES (?, ?, ?, ?, ?)",
      [username, hashedPassword, email, gender, birthdate]
    );

    return { message: "User registered successfully" };
  } finally {
    connection.release();
  }
}

// 로그인 로직
async function loginUser(pool, username, password) {
  const connection = await pool.getConnection();
  try {
    const [users] = await connection.query(
      "SELECT * FROM users WHERE username = ?",
      [username]
    );
    if (users.length === 0) {
      throw new Error("Invalid username or password");
    }

    const user = users[0];
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error("Invalid username or password");
    }

    const token = jwt.sign({ userId: user.id, username: user.username }, SECRET_KEY, {
      expiresIn: "1h",
    });

    return { message: "Login successful", token };
  } finally {
    connection.release();
  }
}

module.exports = router;