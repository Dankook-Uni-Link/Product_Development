const express = require("express");
const ejs = require("ejs");
const fs = require("fs");
const path = require("path");
const app = express();
const cors = require("cors");
const port = 3000;

app.use(cors());
app.use(express.json()); // POST 요청에서 JSON 본문을 파싱하기 위한 미들웨어 추가

// 특정 파일의 JSON 데이터를 읽어오는 함수
function readJsonFileSync(filepath, encoding = "utf8") {
  const file = fs.readFileSync(filepath, encoding);
  return JSON.parse(file);
}

// Load login data from file
function getUserInfo() {
  const filepath = path.join(__dirname, "login", "logins.json");
  return readJsonFileSync(filepath);
}

// EJS configuration (if needed for templates)
app.set("view engine", "ejs");
// app.set("login", "./login");

// Route to fetch all user data
app.get("/login", (req, res) => {
  try {
    const users = getUserInfo(); // Get all users
    res.json({ success: true, users }); // Respond with all users as an array
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load logins");
  }
});

app.post("/login", (req, res) => {
  try {
    const { username, password } = req.body; // Extract email and password
    const users = getUserInfo(); // Get all users
    console.log(users);

    // Find the user by email
    const user = users.find((user) => user.username === username);
    console.log();
    console.log(user);

    if (!user) {
      return res.json({ success: false, message: "사용자를 찾을 수 없습니다." });
    }

    // Check password
    if (user.password !== password) {
      return res.json({ success: false, message: "비밀번호가 틀렸습니다." });
    }

    // Login success
    return res.json({ success: true, message: "로그인 성공", user });
  } catch (error) {
    console.error(error);
    res.status(500).send("로그인 처리 중 오류가 발생했습니다.");
  }
});

// 회원가입
// 상대 경로로 logins.json 파일을 불러오기
const loginsFilePath = path.join(__dirname, './login/logins.json');

// Route to fetch all user data
app.get("/signup", (req, res) => {
  try {
    const users = getUserInfo(); // Get all users
    res.json({ success: true, users }); // Respond with all users as an array
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load signup");
  }
});

app.post("/signup", (req, res) => {
  const { username, password, email, gender, birthdate, region, job} = req.body;

  // 새로운 유저 객체 생성
  const newUser = {
    id: Date.now(), // 고유 ID 생성
    username,
    password,
    email,
    gender,
    birthdate,
    region,
    job,
  };
  console.log(newUser);

  // logins.json 파일 읽기
  let users = [];
  fs.readFile('./login/logins.json', (err, data) => {
    if (err) {
      if (err.code === 'ENOENT') {
        // 파일이 없으면 새로운 파일 생성
        console.log('logins.json 파일이 없어서 새로 만듭니다.');
      } else {
        // 다른 오류 처리
        return res.status(500).json({ success: false, message: '파일 읽기 실패' });
      }
    } else {
      // 파일이 존재하면 데이터를 파싱
      try {
        users = JSON.parse(data);
      } catch (parseErr) {
        return res.status(500).json({ success: false, message: '파일 파싱 실패' });
      }
    }

    // const users = JSON.parse(data); // JSON 데이터 파싱
    users.push(newUser); // 새로운 유저 추가

    // logins.json 파일 쓰기
    fs.writeFile('./login/logins.json', JSON.stringify(users, null, 2), (writeErr) => {
      if (writeErr) {
        return res.status(500).json({ success: false, message: '파일 저장 실패' });
      }

      res.status(200).json({ success: true, message: '회원가입 성공', user: newUser });
    });
  });
});

// 전체 설문조사 목록을 가져오는 함수
function getAllSurveys() {
  const dirPath = path.join(__dirname, "data");
  const files = fs.readdirSync(dirPath);
  return files.map((file) => getSurveyData(file));
}

// 설문조사 데이터를 가져오는 함수
function getSurveyData(filename) {
  const filepath = path.join(__dirname, "data", filename); // data 폴더에 있는 파일을 읽어옴
  return readJsonFileSync(filepath);
}

// 기프티콘 데이터를 가져오는 함수
function getGifticonData() {
  const filepath = path.join(__dirname, "gifticon", "gifticons.json");
  return readJsonFileSync(filepath);
}

// 라우팅
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

// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
