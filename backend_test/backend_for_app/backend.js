const express = require("express");
const ejs = require("ejs");
const fs = require("fs");
const path = require("path");
const app = express();
const port = 3000;
const users = new Map(); // 사용자 정보를 저장하는 Map

// POST 요청의 body를 파싱하기 위한 미들웨어 추가
app.use(express.json());

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

// 새로운 설문을 저장하는 함수
function saveSurvey(surveyData) {
  const dirPath = path.join(__dirname, "data");
  const files = fs.readdirSync(dirPath);
  const newId = files.length + 1;
  const filepath = path.join(dirPath, `${newId}.json`);

  fs.writeFileSync(filepath, JSON.stringify(surveyData, null, 2));
  return newId;
}

// 뷰 엔진 설정
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

// POST 요청 처리 추가
app.post("/surveys", (req, res) => {
  try {
    const surveyData = req.body;
    const newId = saveSurvey(surveyData);
    res.status(201).json({ id: newId, message: "Survey created successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to create survey");
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

// 포인트 내역 조회
app.get("/points/history", (req, res) => {
  try {
    const pointHistory = readJsonFileSync(
      path.join(__dirname, "points", "points_history.json")
    );
    res.json(pointHistory);
  } catch (error) {
    res.status(500).send("Failed to load point history");
  }
});

// 현재 포인트 조회
app.get("/points/current", (req, res) => {
  try {
    const currentPoints = readJsonFileSync(
      path.join(__dirname, "points", "current_points.json")
    );
    res.json(currentPoints);
  } catch (error) {
    res.status(500).send("Failed to load current points");
  }
});

// 설문 통계 조회
app.get("/survey/:id/stats", (req, res) => {
  try {
    const surveyStats = readJsonFileSync(
      path.join(__dirname, "stats", `survey_${req.params.id}_stats.json`)
    );
    res.json(surveyStats);
  } catch (error) {
    res.status(500).send("Failed to load survey statistics");
  }
});

// 회원가입 엔드포인트
app.post("/auth/signup", (req, res) => {
  const { email, password, name, birthDate, gender, location, occupation } =
    req.body;

  if (users.has(email)) {
    return res.status(400).json({ message: "이미 존재하는 이메일입니다." });
  }

  const user = {
    id: users.size + 1,
    email,
    password, // 실제로는 암호화 필요
    name,
    birthDate,
    gender,
    location,
    occupation,
    createdAt: new Date(),
  };

  users.set(email, user);
  res.status(201).json({ ...user, password: undefined });
});

// 로그인 엔드포인트
app.post("/auth/login", (req, res) => {
  const { email, password } = req.body;
  console.log("Login attempt:", { email, password });
  console.log("Current users:", users); // users Map의 현재 상태 확인

  const user = users.get(email);
  console.log("Found user:", user);

  if (!user || user.password !== password) {
    return res
      .status(401)
      .json({ message: "이메일 또는 비밀번호가 일치하지 않습니다." });
  }

  // JWT 토큰 대신 임시로 간단한 토큰 사용
  const token = Buffer.from(email).toString("base64");
  res.json({ token, user: { ...user, password: undefined } });
});

app.listen(port);
