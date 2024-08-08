const express = require("express");
const ejs = require("ejs");
const fs = require("fs");
const path = require("path");
const app = express();
const port = 3000;

// 특정 파일의 JSON 데이터를 읽어오는 함수
function readJsonFileSync(filepath, encoding) {
  if (typeof encoding === "undefined") {
    encoding = "utf8";
  }
  const file = fs.readFileSync(filepath, encoding);
  return JSON.parse(file);
}

// 파일 경로로부터 JSON 데이터를 읽어오는 함수
function getSurveyData(filename) {
  const filepath = path.join(__dirname, "data", filename); // data 폴더에 있는 파일을 읽어옴
  return readJsonFileSync(filepath);
}

// 전체 설문조사 목록을 가져오는 함수
function getAllSurveys() {
  const dirPath = path.join(__dirname, "data");
  const files = fs.readdirSync(dirPath);
  return files.map((file) => getSurveyData(file));
}

// 기프티콘 데이터를 가져오는 함수
function getGifticonData() {
  const filepath = path.join(__dirname, "gifticon", "gifticons.json");
  return readJsonFileSync(filepath);
}

app.set("view engine", "ejs");
app.set("survey", "./survey");

//라우팅
app.get("/", (req, res) => {
  res.send("Hello World");
});

app.get("/surveys", (req, res) => {
  try {
    const surveys = getAllSurveys();
    res.json(surveys);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load surveys");
  }
});

app.get("/survey/:id", (req, res) => {
  const surveyId = req.params.id;
  try {
    const surveyData = getSurveyData(`${surveyId}.json`);
    res.json(surveyData);
  } catch (error) {
    res.status(404).send("Survey not found");
  }
});

// 기프티콘 데이터를 제공하는 라우트
app.get("/gifticons", (req, res) => {
  try {
    const gifticons = getGifticonData();
    res.json(gifticons);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load gifticons");
  }
});

app.listen(port);
