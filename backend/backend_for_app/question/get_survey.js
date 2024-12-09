const express = require("express");
const pool = require("../db");
const router = express.Router();

// 설문 전체 가져오기
router.get("/", async (req, res) => {
  try {
    const surveys = await getAllSurveys(pool);
    res.json(surveys);
  } catch (error) {
    console.error(error);
    res.status(500).send("Failed to load surveys");
  }
});

// 특정 설문 가져오기
router.get("/:id", async (req, res) => {
  const surveyId = req.params.id;
  try {
    const surveyData = await getSurveyData(pool, surveyId);
    res.json(surveyData);
  } catch (error) {
    if (error.message === "Survey not found") {
      res.status(404).send("Survey not found");
    } else {
      console.error(error);
      res.status(500).send("Failed to load survey");
    }
  }
});

// 설문 관련 함수들
async function getAllSurveys(pool) {
  const connection = await pool.getConnection();
  try {
    const [surveys] = await connection.query("SELECT * FROM survey");

    const surveysWithDetails = await Promise.all(
      surveys.map(async (survey) => {
        const [questions] = await connection.query(
          "SELECT id, question, question_type FROM questions WHERE survey_id = ?",
          [survey.id]
        );

        const questionsWithOptions = await Promise.all(
          questions.map(async (question) => {
            const [options] = await connection.query(
              "SELECT option_text FROM options WHERE question_id = ?",
              [question.id]
            );
            return {
              question: question.question,
              type: question.question_type,
              options: options.map((opt) => opt.option_text),
            };
          })
        );

        return {
          surveyTitle: survey.survey_title,
          surveyDescription: survey.survey_description,
          totalQuestions: survey.total_questions,
          reward: survey.reward,
          targetNumber: survey.target_number,
          winningNumber: survey.winning_number,
          price: survey.price,
          questions: questionsWithOptions,
        };
      })
    );

    return surveysWithDetails;
  } finally {
    connection.release();
  }
}

async function getSurveyData(pool, surveyId) {
  const connection = await pool.getConnection();
  try {
    const [surveys] = await connection.query(
      "SELECT * FROM survey WHERE id = ?",
      [surveyId]
    );

    if (surveys.length === 0) {
      throw new Error("Survey not found");
    }

    const survey = surveys[0];
    const [questions] = await connection.query(
      "SELECT id, question, question_type FROM questions WHERE survey_id = ?",
      [survey.id]
    );

    const questionsWithOptions = await Promise.all(
      questions.map(async (question) => {
        const [options] = await connection.query(
          "SELECT option_text FROM options WHERE question_id = ?",
          [question.id]
        );
        return {
          question: question.question,
          type: question.question_type,
          options: options.map((opt) => opt.option_text),
        };
      })
    );

    return {
      surveyTitle: survey.survey_title,
      surveyDescription: survey.survey_description,
      totalQuestions: survey.total_questions,
      reward: survey.reward,
      targetNumber: survey.target_number,
      winningNumber: survey.winning_number,
      price: survey.price,
      questions: questionsWithOptions,
    };
  } finally {
    connection.release();
  }
}

module.exports = router;
