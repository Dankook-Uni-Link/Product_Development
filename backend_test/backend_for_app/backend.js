//백엔드 서버의 메인 파일 // API 서버 파일

// 1. 모듈 임포트
const express = require("express");
const ejs = require("ejs");
const fs = require("fs");
const path = require("path");

// 2. 앱 초기화 및 기본 설정
const app = express();
const port = 3000;
//const users = new Map(); // 사용자 정보를 저장하는 Map
// POST 요청의 body를 파싱하기 위한 미들웨어 추가
app.use(express.json());
// 뷰 엔진 설정
app.set("view engine", "ejs");
app.set("survey", "./survey");

// 특정 파일의 JSON 데이터를 읽어오는 함수
function readJsonFileSync(filepath, encoding) {
  if (typeof encoding === "undefined") {
    encoding = "utf8";
  }
  const file = fs.readFileSync(filepath, encoding);
  return JSON.parse(file);
}

function getSurveyData(filename) {
  const filepath = path.join(__dirname, "data", filename);
  const surveyData = readJsonFileSync(filepath);
  const id = parseInt(filename.split(".")[0]);
  return {
    ...surveyData,
    id: id,
  };
}

// 전체 설문조사 목록을 가져오는 함수
function getAllSurveys() {
  const dirPath = path.join(__dirname, "data");
  const files = fs.readdirSync(dirPath);
  return files.map((file) => {
    const surveyData = getSurveyData(file);
    // 파일명에서 ID 추출 (예: "1.json" -> 1)
    const id = parseInt(file.split(".")[0]);
    return {
      ...surveyData,
      id: id,
    };
  });
}

// 새로운 설문을 저장하는 함수
function saveSurvey(surveyData) {
  const dirPath = path.join(__dirname, "data");
  const files = fs.readdirSync(dirPath);
  const newId = files.length + 1;
  const filepath = path.join(dirPath, `${newId}.json`);

  // surveyData에 id 추가
  const surveyWithId = {
    ...surveyData,
    id: newId, // 이 부분이 있는지 확인
  };

  fs.writeFileSync(filepath, JSON.stringify(surveyWithId, null, 2));
  return newId;
}

// 설문 참여자 수 업데이트 함수
function updateSurveyParticipants(surveyId) {
  const surveyPath = path.join(__dirname, "data", `${surveyId}.json`);
  const survey = JSON.parse(fs.readFileSync(surveyPath, "utf8"));

  // 현재 응답자 수 증가
  survey.currentResponses = (survey.currentResponses || 0) + 1;

  // 파일에 저장
  fs.writeFileSync(surveyPath, JSON.stringify(survey, null, 2));
  return survey;
}

const updateSurveyStats = (surveyId, userId, responses) => {
  // stats 폴더가 없으면 생성
  const statsDir = path.join(__dirname, "stats");
  if (!fs.existsSync(statsDir)) {
    fs.mkdirSync(statsDir);
  }

  const statsPath = path.join(
    __dirname,
    "stats",
    `survey_${surveyId}_stats.json`
  );

  // 기존 stats 읽기 또는 초기화
  let stats;
  try {
    stats = JSON.parse(fs.readFileSync(statsPath, "utf8"));
  } catch {
    stats = {
      summary: {
        totalResponses: 0,
        lastUpdated: new Date().toISOString(),
      },
      questions: {},
    };
  }

  // 응답 수 업데이트
  stats.summary.totalResponses += 1;
  stats.summary.lastUpdated = new Date().toISOString();

  // 응답 데이터 집계
  Object.entries(responses).forEach(([questionId, answers]) => {
    if (!stats.questions[questionId]) {
      stats.questions[questionId] = {
        responses: {},
      };
    }

    // answers가 배열인 경우 각 답변을 개별적으로 카운트
    if (Array.isArray(answers)) {
      answers.forEach((answer) => {
        stats.questions[questionId].responses[answer] =
          (stats.questions[questionId].responses[answer] || 0) + 1;
      });
    }
  });

  // 파일 저장
  fs.writeFileSync(statsPath, JSON.stringify(stats, null, 2));

  return stats;
};

// 유저 정보 저장 함수
function saveUserProfile(userData) {
  const userDir = path.join(__dirname, "users", "profiles");
  const filePath = path.join(userDir, `${userData.id}.json`);

  // 디렉토리가 없으면 생성
  if (!fs.existsSync(userDir)) {
    fs.mkdirSync(userDir, { recursive: true });
  }

  // 기본 활동 정보 생성
  const activitiesDir = path.join(__dirname, "users", "activities");
  const activitiesPath = path.join(activitiesDir, `${userData.id}.json`);
  if (!fs.existsSync(activitiesDir)) {
    fs.mkdirSync(activitiesDir, { recursive: true });
  }

  // 기본 포인트 정보 생성
  const pointsDir = path.join(__dirname, "users", "points");
  const pointsPath = path.join(pointsDir, `${userData.id}.json`);
  if (!fs.existsSync(pointsDir)) {
    fs.mkdirSync(pointsDir, { recursive: true });
  }

  // 각 파일 저장
  fs.writeFileSync(filePath, JSON.stringify(userData, null, 2));
  fs.writeFileSync(
    activitiesPath,
    JSON.stringify(
      {
        created_surveys: [],
        participated_surveys: [],
      },
      null,
      2
    )
  );
  fs.writeFileSync(
    pointsPath,
    JSON.stringify(
      {
        currentPoints: 0,
        history: [],
      },
      null,
      2
    )
  );
}

// 유저 프로필 읽기 함수 추가
function getUserByEmail(email) {
  const userDir = path.join(__dirname, "users", "profiles");
  if (!fs.existsSync(userDir)) return null;

  const files = fs.readdirSync(userDir);
  for (const file of files) {
    const userData = JSON.parse(
      fs.readFileSync(path.join(userDir, file), "utf8")
    );
    if (userData.email === email) {
      return userData;
    }
  }
  return null;
}

// 사용자 프로필 전체 정보 가져오는 함수
function getUserProfile(userId) {
  try {
    // 프로필 정보 가져오기
    const profilePath = path.join(
      __dirname,
      "users",
      "profiles",
      `${userId}.json`
    );
    const activitiesPath = path.join(
      __dirname,
      "users",
      "activities",
      `${userId}.json`
    );
    const pointsPath = path.join(
      __dirname,
      "users",
      "points",
      `${userId}.json`
    );

    const profile = JSON.parse(fs.readFileSync(profilePath, "utf8"));
    const activities = JSON.parse(fs.readFileSync(activitiesPath, "utf8"));
    const points = JSON.parse(fs.readFileSync(pointsPath, "utf8"));

    // 전체 프로필 정보 반환
    return {
      ...profile,
      activities,
      points,
      password: undefined, // 보안을 위해 비밀번호 제외
    };
  } catch (error) {
    console.error("Error reading user profile:", error);
    return null;
  }
}

// 가장 최근 유저 ID를 가져오는 함수
function getLatestUserId() {
  const userDir = path.join(__dirname, "users", "profiles");
  if (!fs.existsSync(userDir)) {
    return 0;
  }

  const files = fs.readdirSync(userDir);
  if (files.length === 0) {
    return 0;
  }

  // 파일명에서 ID 추출 (파일명: "1.json", "2.json" 등)
  const userIds = files.map((file) => parseInt(path.parse(file).name));
  return Math.max(...userIds);
}

// 기프티콘 데이터를 가져오는 함수
function getGifticonData() {
  const filepath = path.join(__dirname, "gifticon", "gifticons.json");
  return readJsonFileSync(filepath);
}

// 포인트 업데이트 함수 수정
function updateUserPoints(userId, pointChange, title) {
  const pointsPath = path.join(__dirname, "users", "points", `${userId}.json`);

  try {
    // 현재 포인트 데이터 읽기
    const pointData = JSON.parse(fs.readFileSync(pointsPath, "utf8"));

    // 포인트 업데이트
    pointData.currentPoints += pointChange;

    // 히스토리에 기록 추가
    pointData.history.push({
      title: title,
      date: new Date().toISOString(),
      points: Math.abs(pointChange),
      type: pointChange > 0 ? "earn" : "use",
    });

    // 업데이트된 데이터 저장
    fs.writeFileSync(pointsPath, JSON.stringify(pointData, null, 2));

    return pointData;
  } catch (error) {
    console.error("Error updating user points:", error);
    throw error;
  }
}

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

app.post("/surveys", (req, res) => {
  try {
    const surveyData = req.body;
    console.log("Creating survey with data:", surveyData); // 요청 데이터 확인
    console.log("Creator ID:", surveyData.creatorId); // creatorId 확인

    // 새로운 설문 ID 생성 및 저장
    const newId = saveSurvey(surveyData);

    // 생성자의 activities 파일 경로
    const activitiesPath = path.join(
      __dirname,
      "users",
      "activities",
      `${surveyData.creatorId}.json`
    );
    console.log("Activities file path:", activitiesPath); // 파일 경로 확인

    // activities 파일 읽기
    let activities = JSON.parse(fs.readFileSync(activitiesPath, "utf8"));

    // created_surveys 배열에 새 설문 추가
    activities.created_surveys.push({
      surveyId: newId,
      createdAt: new Date().toISOString(),
    });

    // 업데이트된 activities 저장
    fs.writeFileSync(activitiesPath, JSON.stringify(activities, null, 2));

    res.status(201).json({ success: true, id: newId });
  } catch (error) {
    console.error("Survey creation error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create survey",
      error: error.message, // 상세 에러 메시지 추가
    });
  }
});

app.post("/surveys/:surveyId/participate", async (req, res) => {
  try {
    const surveyId = parseInt(req.params.surveyId);
    const { userId, responses } = req.body;

    // 1. 중복 참여 체크
    const activitiesPath = path.join(
      __dirname,
      "users",
      "activities",
      `${userId}.json`
    );
    let activities = JSON.parse(fs.readFileSync(activitiesPath, "utf8"));

    const hasParticipated = activities.participated_surveys.some(
      (survey) => survey.surveyId === surveyId
    );

    if (hasParticipated) {
      return res.status(400).json({
        success: false,
        message: "이미 참여한 설문입니다.",
      });
    }

    // 2. 통계 데이터 업데이트
    const updatedStats = updateSurveyStats(surveyId, userId, responses);

    // 3. 설문 참여자 수 업데이트
    const updatedSurvey = updateSurveyParticipants(surveyId);

    // 4. 포인트 업데이트 - 설문의 보상 포인트만큼 지급
    const pointResult = await updateUserPoints(
      userId,
      updatedSurvey.rewardAmount,
      `${updatedSurvey.title}` // 설문 제목을 포인트 내역에 추가
    );

    // 5. activities 업데이트
    activities.participated_surveys.push({
      surveyId: surveyId,
      participatedAt: new Date().toISOString(),
      responses: responses,
    });
    fs.writeFileSync(activitiesPath, JSON.stringify(activities, null, 2));

    res.status(200).json({
      success: true,
      message: "Survey participation recorded successfully",
      updatedSurvey,
      stats: updatedStats,
      points: {
        earned: updatedSurvey.rewardAmount,
        current: pointResult.currentPoints,
      },
    });
  } catch (error) {
    console.error("Survey participation error:", error);
    res.status(500).json({
      success: false,
      message: "참여 처리 중 오류가 발생했습니다.",
      error: error.message,
    });
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

// 회원가입 엔드포인트 수정
app.post("/auth/signup", (req, res) => {
  const { email, password, name, birthDate, gender, location, occupation } =
    req.body;

  // 이메일 중복 체크
  const existingUser = getUserByEmail(email);
  if (existingUser) {
    return res.status(400).json({ message: "이미 존재하는 이메일입니다." });
  }

  // 새로운 유저 ID 생성
  const newUserId = getLatestUserId() + 1;

  const user = {
    id: newUserId,
    email,
    password, // 실제로는 암호화 필요
    name,
    birthDate,
    gender,
    location,
    occupation,
    createdAt: new Date().toISOString(),
  };

  try {
    saveUserProfile(user);
    res.status(201).json({ ...user, password: undefined });
  } catch (error) {
    console.error("Error saving user profile:", error);
    res.status(500).json({ message: "Failed to save user profile" });
  }
});

// 로그인 엔드포인트 수정
app.post("/auth/login", (req, res) => {
  const { email, password } = req.body;
  const user = getUserByEmail(email);

  if (!user || user.password !== password) {
    return res
      .status(401)
      .json({ message: "이메일 또는 비밀번호가 일치하지 않습니다." });
  }

  const token = Buffer.from(email).toString("base64");
  res.json({ token, user: { ...user, password: undefined } });
});

// 프로필 조회 엔드포인트 추가
app.get("/users/:userId/profile", (req, res) => {
  const userId = req.params.userId;
  const profile = getUserProfile(userId);

  if (!profile) {
    return res.status(404).json({ message: "User not found" });
  }

  res.json(profile);
});

//
app.get("/users/:userId/surveys", (req, res) => {
  const userId = req.params.userId;
  try {
    // activities 파일에서 created_surveys 정보 조회
    const activitiesPath = path.join(
      __dirname,
      "users",
      "activities",
      `${userId}.json`
    );
    const activities = JSON.parse(fs.readFileSync(activitiesPath, "utf8"));

    // 각 설문의 상세 정보 조회
    const surveys = activities.created_surveys.map((item) => {
      const surveyPath = path.join(__dirname, "data", `${item.surveyId}.json`);
      return JSON.parse(fs.readFileSync(surveyPath, "utf8"));
    });

    res.json(surveys);
  } catch (error) {
    console.error("Error loading user surveys:", error);
    res.status(500).json({ message: "Failed to load surveys" });
  }
});

// 사용자의 activities를 가져오는 엔드포인트 추가
app.get("/users/:userId/activities", (req, res) => {
  try {
    const userId = req.params.userId;
    const activitiesPath = path.join(
      __dirname,
      "users",
      "activities",
      `${userId}.json`
    );

    // activities 파일 읽기
    const activities = JSON.parse(fs.readFileSync(activitiesPath, "utf8"));

    res.json(activities);
  } catch (error) {
    console.error("Error fetching user activities:", error);
    res.status(500).json({
      success: false,
      message: "Failed to load user activities",
      error: error.message,
    });
  }
});

// 포인트 내역 조회 API
app.get("/users/:userId/points/history", (req, res) => {
  try {
    const userId = req.params.userId;
    const pointsPath = path.join(
      __dirname,
      "users",
      "points",
      `${userId}.json`
    );

    const userData = JSON.parse(fs.readFileSync(pointsPath, "utf8"));
    res.json(userData.history);
  } catch (error) {
    console.error("Error loading point history:", error);
    res.status(500).json({
      success: false,
      message: "Failed to load point history",
      error: error.message,
    });
  }
});

// 현재 포인트 조회 API
app.get("/users/:userId/points/current", (req, res) => {
  try {
    const userId = req.params.userId;
    const pointsPath = path.join(
      __dirname,
      "users",
      "points",
      `${userId}.json`
    );

    const userData = JSON.parse(fs.readFileSync(pointsPath, "utf8"));
    res.json({
      success: true,
      currentPoints: userData.currentPoints,
    });
  } catch (error) {
    console.error("Error loading current points:", error);
    res.status(500).json({
      success: false,
      message: "Failed to load current points",
      error: error.message,
    });
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

app.listen(port, () => {
  console.log(`Server is running on 3000`);
});
