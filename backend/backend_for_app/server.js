const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");
const { getAllSurveys, getSurveyData, getGifticonData } = require("./question/get_survey");

const app = express();
const port = 3000;

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

app.use(cors());

// Routes
app.get("/", (req, res) => {
  res.send("Hello World");
});

// Get all surveys
app.get("/surveys", async (req, res) => {
  try {
    const surveys = await getAllSurveys(pool);
    res.json(surveys);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load surveys");
  }
});

// Get specific survey by id
app.get("/survey/:id", async (req, res) => {
  const surveyId = req.params.id;
  try {
    const surveyData = await getSurveyData(pool, surveyId);
    res.json(surveyData);
  } catch (error) {
    if (error.message === 'Survey not found') {
      res.status(404).send("Survey not found");
    } else {
      console.error(error);
      res.status(500).send("Failed to load survey");
    }
  }
});

// Get gifticon data
app.get("/gifticons", (req, res) => {
  try {
    const gifticons = getGifticonData();
    res.json(gifticons);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load gifticons");
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
