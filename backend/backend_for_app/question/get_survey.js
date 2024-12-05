const path = require("path");
const fs = require("fs");

// Get all surveys
async function getAllSurveys(pool) {
  const connection = await pool.getConnection();
  try {
    const [surveys] = await connection.query('SELECT * FROM survey');

    const surveysWithDetails = await Promise.all(surveys.map(async (survey) => {
      const [questions] = await connection.query('SELECT id, question, question_type FROM questions WHERE survey_id = ?', [survey.id]);

      const questionsWithOptions = await Promise.all(questions.map(async (question) => {
        const [options] = await connection.query('SELECT option_text FROM options WHERE question_id = ?', [question.id]);
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

// Get survey data by id
async function getSurveyData(pool, surveyId) {
  const connection = await pool.getConnection();
  try {
    const [surveys] = await connection.query('SELECT * FROM survey WHERE id = ?', [surveyId]);

    if (surveys.length === 0) {
      throw new Error('Survey not found');
    }

    const survey = surveys[0];
    const [questions] = await connection.query('SELECT id, question, question_type FROM questions WHERE survey_id = ?', [survey.id]);

    const questionsWithOptions = await Promise.all(questions.map(async (question) => {
      const [options] = await connection.query('SELECT option_text FROM options WHERE question_id = ?', [question.id]);
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

// Get gifticon data
function getGifticonData() {
  const filepath = path.join(__dirname, "gifticon", "gifticons.json");
  return JSON.parse(fs.readFileSync(filepath, "utf8"));
}

module.exports = {
  getAllSurveys,
  getSurveyData,
  getGifticonData
};
