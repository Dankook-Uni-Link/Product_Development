const express = require("express");
const cors = require("cors");
const db = require("./db");
const surveyRoutes = require("./question/get_survey");
const authRoutes = require("./user/auth");

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get("/", (req, res) => {
  res.send("Hello World");
});

// 설문 관련 라우트
app.use("/surveys", surveyRoutes);

// 사용자 관련 라우트
app.use("/auth", authRoutes);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});