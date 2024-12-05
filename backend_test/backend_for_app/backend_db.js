const express = require("express");
const mysql = require("mysql2/promise");
const path = require("path");
const cors = require("cors");
const app = express();
const port = 3000;

app.use(cors());

// MySQL 연결 설정
const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "1234",
  database: "flutter_db",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// 전체 설문조사 목록을 가져오는 함수
async function getAllSurveys() {
  const connection = await pool.getConnection();
  try {
    // 설문조사 기본 정보 가져오기
    const [surveys] = await connection.query('SELECT * FROM survey');
    
    // 각 설문조사에 대한 질문과 옵션 가져오기
    const surveysWithDetails = await Promise.all(surveys.map(async (survey) => {
      // 질문 가져오기
      const [questions] = await connection.query(
        'SELECT id, question, question_type FROM questions WHERE survey_id = ?', 
        [survey.id]
      );
      
      // 각 질문의 옵션 가져오기
      const questionsWithOptions = await Promise.all(questions.map(async (question) => {
        const [options] = await connection.query(
          'SELECT option_text FROM options WHERE question_id = ?', 
          [question.id]
        );
        
        return {
          question: question.question,
          type: question.question_type,
          options: options.map(opt => opt.option_text)
        };
      }));
      
      return {
        surveyTitle: survey.survey_title,
        surveyDescription: survey.survey_description,
        totalQuestions: survey.total_questions,
        reward: survey.reward,
        Target_number: survey.target_number,
        winning_number: survey.winning_number,
        price: survey.price,
        questions: questionsWithOptions
      };
    }));
    
    return surveysWithDetails;
  } finally {
    connection.release();
  }
}

// 특정 설문조사 데이터를 가져오는 함수
async function getSurveyData(surveyId) {
  const connection = await pool.getConnection();
  try {
    // 설문조사 기본 정보 가져오기
    const [surveys] = await connection.query('SELECT * FROM survey WHERE id = ?', [surveyId]);
    
    if (surveys.length === 0) {
      throw new Error('Survey not found');
    }
    
    const survey = surveys[0];
    
    // 질문 가져오기
    const [questions] = await connection.query(
      'SELECT id, question, question_type FROM questions WHERE survey_id = ?', 
      [survey.id]
    );
    
    // 각 질문의 옵션 가져오기
    const questionsWithOptions = await Promise.all(questions.map(async (question) => {
      const [options] = await connection.query(
        'SELECT option_text FROM options WHERE question_id = ?', 
        [question.id]
      );
      
      return {
        question: question.question,
        type: question.question_type,
        options: options.map(opt => opt.option_text)
      };
    }));
    
    return {
      surveyTitle: survey.survey_title,
      surveyDescription: survey.survey_description,
      totalQuestions: survey.total_questions,
      reward: survey.reward,
      Target_number: survey.target_number,
      winning_number: survey.winning_number,
      price: survey.price,
      questions: questionsWithOptions
    };
  } finally {
    connection.release();
  }
}

// 기프티콘 데이터를 가져오는 함수
function getGifticonData() {
  const filepath = path.join(__dirname, "gifticon", "gifticons.json");
  return JSON.parse(fs.readFileSync(filepath, "utf8"));
}

// 라우팅
app.get("/", (req, res) => {
  res.send("Hello World");
});

app.get("/surveys", async (req, res) => {
  try {
    const surveys = await getAllSurveys();
    res.json(surveys);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load surveys");
  }
});

app.get("/survey/:id", async (req, res) => {
  const surveyId = req.params.id;
  try {
    const surveyData = await getSurveyData(surveyId);
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
  console.log(`Server running on port ${port}`);
});
