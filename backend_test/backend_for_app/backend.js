// backend.js 최상단에 pool import 추가
const express = require("express");
const ejs = require("ejs");
const pool = require("./db"); // 추가

const app = express();
const port = 3000;

app.use(express.json());
app.set("view engine", "ejs");
app.set("survey", "./survey");

// // saveUserProfile 함수 수정
// async function saveUserProfile(userData) {
//   const connection = await pool.getConnection();
//   try {
//     await connection.beginTransaction();

//     // 1. users 테이블에 기본 정보 저장
//     const [result] = await connection.query(
//       `INSERT INTO users (email, password, name, birth_date, gender, location, occupation)
//        VALUES (?, ?, ?, ?, ?, ?, ?)`,
//       [
//         userData.email,
//         userData.password,
//         userData.name,
//         userData.birthDate,
//         userData.gender,
//         userData.location,
//         userData.occupation,
//       ]
//     );

//     const userId = result.insertId;

//     // 2. user_points 테이블에 초기 포인트 정보 생성
//     await connection.query(
//       "INSERT INTO user_points (user_id, current_points) VALUES (?, 0)",
//       [userId]
//     );

//     await connection.commit();
//     return userId;
//   } catch (error) {
//     await connection.rollback();
//     throw error;
//   } finally {
//     connection.release();
//   }
// }

async function saveUserProfile(userData) {
  const connection = await pool.getConnection();
  try {
    // validation 추가
    const requiredFields = [
      "email",
      "password",
      "name",
      "birthDate",
      "gender",
      "location",
      "occupation",
    ];
    for (const field of requiredFields) {
      if (!userData[field]) {
        throw new Error(`${field} is required`);
      }
    }

    await connection.beginTransaction();

    const [result] = await connection.query(
      `INSERT INTO users (email, password, name, birth_date, gender, location, occupation)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        userData.email,
        userData.password,
        userData.name,
        userData.birthDate,
        userData.gender,
        userData.location,
        userData.occupation,
      ]
    );

    const userId = result.insertId;
    await connection.query(
      "INSERT INTO user_points (user_id, current_points) VALUES (?, 0)",
      [userId]
    );

    await connection.commit();
    return userId;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// getUserByEmail 함수 수정
async function getUserByEmail(email) {
  const [rows] = await pool.query("SELECT * FROM users WHERE email = ?", [
    email,
  ]);
  return rows[0];
}

// getUserProfile 함수 수정
async function getUserProfile(userId) {
  try {
    // 1. 사용자 기본 정보와 포인트 정보를 JOIN하여 조회
    const [rows] = await pool.query(
      `SELECT u.*, up.current_points 
       FROM users u 
       LEFT JOIN user_points up ON u.id = up.user_id 
       WHERE u.id = ?`,
      [userId]
    );

    if (!rows.length) {
      return null;
    }

    // 2. 사용자의 설문 참여 내역 조회
    const [responses] = await pool.query(
      `SELECT sr.survey_id, sr.created_at as participated_at, sr.response_data
       FROM survey_responses sr
       WHERE sr.user_id = ?`,
      [userId]
    );

    // 3. 응답 데이터 구조화
    return {
      ...rows[0],
      password: undefined,
      activities: {
        participated_surveys: responses,
      },
    };
  } catch (error) {
    console.error("Error reading user profile:", error);
    throw error;
  }
}

// // 회원가입 엔드포인트 수정
// app.post("/auth/signup", async (req, res) => {
//   try {
//     const { email, password, name, birthDate, gender, location, occupation } =
//       req.body;
//     const parsedBirthDate = new Date(birthDate);
//     const formattedBirthDate = parsedBirthDate.toISOString().split("T")[0];

//     // 이메일 중복 체크
//     const existingUser = await getUserByEmail(email);
//     if (existingUser) {
//       return res.status(400).json({ message: "이미 존재하는 이메일입니다." });
//     }

//     // 새 사용자 저장
//     const userId = await saveUserProfile({
//       email,
//       password, // 실제로는 암호화 필요
//       name,
//       birthDate,
//       gender,
//       location,
//       occupation,
//     });

//     const user = await getUserProfile(userId);
//     res.status(201).json(user);
//   } catch (error) {
//     console.error("Error in signup:", error);
//     res.status(500).json({ message: "Failed to create user" });
//   }
// });

// app.post("/auth/signup", async (req, res) => {
//   try {
//     const { email, password, name, birthDate, gender, location, occupation } =
//       req.body;

//     // 필수 필드 검증
//     if (
//       !email ||
//       !password ||
//       !name ||
//       !birthDate ||
//       !gender ||
//       !location ||
//       !occupation
//     ) {
//       return res.status(400).json({
//         message: "모든 필드를 입력해주세요.",
//         missingFields: {
//           email: !email,
//           password: !password,
//           name: !name,
//           birthDate: !birthDate,
//           gender: !gender,
//           location: !location,
//           occupation: !occupation,
//         },
//       });
//     }

//     const parsedBirthDate = new Date(birthDate);
//     if (isNaN(parsedBirthDate.getTime())) {
//       return res.status(400).json({ message: "잘못된 날짜 형식입니다." });
//     }

//     const formattedBirthDate = parsedBirthDate.toISOString().split("T")[0];

//     // 이메일 중복 체크
//     const existingUser = await getUserByEmail(email);
//     if (existingUser) {
//       return res.status(400).json({ message: "이미 존재하는 이메일입니다." });
//     }

//     // 새 사용자 저장
//     const userId = await saveUserProfile({
//       email,
//       password,
//       name,
//       birthDate: formattedBirthDate,
//       gender,
//       location,
//       occupation,
//     });

//     const user = await getUserProfile(userId);
//     res.status(201).json(user);
//   } catch (error) {
//     console.error("Error in signup:", error);
//     res.status(500).json({
//       message: "회원가입 처리 중 오류가 발생했습니다.",
//       error: error.message, // 개발 중에는 상세 에러 메시지 포함
//     });
//   }
// });

app.post("/auth/signup", async (req, res) => {
  try {
    const { email, password, name, birthDate, gender, location, occupation } =
      req.body;

    // 디버깅용 로그
    console.log("Received signup data:", JSON.stringify(req.body, null, 2));

    // 모든 필드가 존재하고 빈 값이 아닌지 확인
    const requiredFields = {
      email,
      password,
      name,
      birthDate,
      gender,
      location,
      occupation,
    };

    // 각 필드의 값을 로그로 출력
    console.log("Field values:", requiredFields);

    const missingFields = Object.entries(requiredFields)
      .filter(([key, value]) => !value || String(value).trim() === "")
      .map(([key]) => key);

    if (missingFields.length > 0) {
      console.log("Missing fields:", missingFields);
      return res.status(400).json({
        message: "모든 필드를 입력해주세요",
        missingFields,
      });
    }

    // 이메일 중복 체크
    const existingUser = await getUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ message: "이미 존재하는 이메일입니다." });
    }

    // 날짜 처리
    const parsedBirthDate = new Date(birthDate);
    const formattedBirthDate = parsedBirthDate.toISOString().split("T")[0];

    // 새 사용자 저장
    const userId = await saveUserProfile({
      email,
      password,
      name,
      birthDate: formattedBirthDate,
      gender,
      location,
      occupation,
    });

    const user = await getUserProfile(userId);
    res.status(201).json(user);
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({
      message: "회원가입 처리 중 오류가 발생했습니다.",
      error: error.message,
    });
  }
});

// 로그인 엔드포인트 수정
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await getUserByEmail(email);

    if (!user || user.password !== password) {
      return res
        .status(401)
        .json({ message: "이메일 또는 비밀번호가 일치하지 않습니다." });
    }

    const token = Buffer.from(email).toString("base64");
    res.json({
      token,
      user: { ...user, password: undefined },
    });
  } catch (error) {
    console.error("Error in login:", error);
    res.status(500).json({ message: "Login failed" });
  }
});

// getAllSurveys 함수 수정
async function getAllSurveys() {
  const [rows] = await pool.query(
    `SELECT s.*, u.name as creator_name, 
       COUNT(sr.id) as response_count
       FROM surveys s
       LEFT JOIN users u ON s.creator_id = u.id
       LEFT JOIN survey_responses sr ON s.id = sr.survey_id
       GROUP BY s.id`
  );
  return rows;
}

async function saveSurvey(surveyData) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 기본 target_conditions 객체
    const defaultTargetConditions = {
      ageRanges: [],
      genders: [],
      locations: [],
      occupations: [],
    };

    const [result] = await connection.query(
      `INSERT INTO surveys (
          creator_id, title, description, questions, 
          reward_amount, target_responses, target_conditions
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        surveyData.creatorId,
        surveyData.title,
        surveyData.description,
        JSON.stringify(surveyData.questions),
        surveyData.rewardAmount,
        surveyData.targetResponses || 100,
        JSON.stringify(surveyData.targetConditions || defaultTargetConditions),
      ]
    );

    const surveyId = result.insertId;
    await connection.commit();
    return surveyId;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

async function updateSurveyStats(surveyId, responses) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. 통계 데이터 존재 확인 및 생성
    const [existingStats] = await connection.query(
      "SELECT 1 FROM survey_statistics WHERE survey_id = ?",
      [surveyId]
    );

    if (!existingStats.length) {
      await connection.query(
        `INSERT INTO survey_statistics (survey_id, total_responses, statistics_data) 
           VALUES (?, 0, '{}')`,
        [surveyId]
      );
    }

    // 2. 현재 통계 데이터 조회
    const [currentStats] = await connection.query(
      "SELECT statistics_data FROM survey_statistics WHERE survey_id = ?",
      [surveyId]
    );

    let statsData = {};
    try {
      statsData =
        typeof currentStats[0]?.statistics_data === "string"
          ? JSON.parse(currentStats[0].statistics_data)
          : currentStats[0]?.statistics_data || {};
    } catch (e) {
      console.error("Error parsing statistics data:", e);
      statsData = {};
    }

    // 3. 응답 데이터 집계
    Object.entries(responses).forEach(([questionId, answers]) => {
      const qId = questionId.toString(); // questionId를 문자열로 변환
      if (!statsData[qId]) {
        statsData[qId] = { responses: {} };
      }

      if (Array.isArray(answers)) {
        answers.forEach((answer) => {
          const answerKey = answer.toString();
          statsData[qId].responses[answerKey] =
            (statsData[qId].responses[answerKey] || 0) + 1;
        });
      }
    });

    // 4. 통계 데이터 업데이트
    console.log("Updating stats:", JSON.stringify(statsData)); // 디버깅용
    await connection.query(
      `UPDATE survey_statistics 
         SET statistics_data = ?, 
             total_responses = total_responses + 1,
             last_updated = CURRENT_TIMESTAMP
         WHERE survey_id = ?`,
      [JSON.stringify(statsData), surveyId]
    );

    await connection.commit();
    return statsData;
  } catch (error) {
    console.error("Error updating survey stats:", error);
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// 설문 참여 API 수정
// app.post("/surveys/:surveyId/participate", async (req, res) => {
//   const connection = await pool.getConnection();
//   try {
//     await connection.beginTransaction();

//     const surveyId = parseInt(req.params.surveyId);
//     const { userId, responses } = req.body;

//     // 중복 참여 체크
//     const [participated] = await connection.query(
//       `SELECT 1 FROM survey_responses
//          WHERE survey_id = ? AND user_id = ?`,
//       [surveyId, userId]
//     );

//     if (participated.length > 0) {
//       return res.status(400).json({
//         success: false,
//         message: "이미 참여한 설문입니다.",
//       });
//     }

//     // 응답 저장
//     await connection.query(
//       `INSERT INTO survey_responses (survey_id, user_id, response_data)
//          VALUES (?, ?, ?)`,
//       [surveyId, userId, JSON.stringify(responses)]
//     );

//     // 설문 응답 수 증가
//     await connection.query(
//       `UPDATE surveys
//          SET current_responses = current_responses + 1
//          WHERE id = ?`,
//       [surveyId]
//     );

//     // 통계 업데이트
//     const statsData = await updateSurveyStats(surveyId, responses);

//     // 포인트 지급
//     const [surveyInfo] = await connection.query(
//       "SELECT reward_amount FROM surveys WHERE id = ?",
//       [surveyId]
//     );

//     await connection.query(
//       `UPDATE user_points
//          SET current_points = current_points + ?
//          WHERE user_id = ?`,
//       [surveyInfo[0].reward_amount, userId]
//     );

//     // 포인트 히스토리 기록
//     await connection.query(
//       `INSERT INTO point_histories (user_id, points, title, type)
//          VALUES (?, ?, ?, 'earn')`,
//       [userId, surveyInfo[0].reward_amount, "설문 참여 보상"]
//     );

//     await connection.commit();

//     res.status(200).json({
//       success: true,
//       message: "설문 참여가 완료되었습니다.",
//       points: {
//         earned: surveyInfo[0].reward_amount,
//       },
//     });
//   } catch (error) {
//     await connection.rollback();
//     console.error("Survey participation error:", error);
//     res.status(500).json({
//       success: false,
//       message: "참여 처리 중 오류가 발생했습니다.",
//     });
//   } finally {
//     connection.release();
//   }
// });

// app.post("/surveys/:surveyId/participate", async (req, res) => {
//   const connection = await pool.getConnection();
//   try {
//     await connection.beginTransaction();

//     const surveyId = parseInt(req.params.surveyId);
//     const { userId, responses } = req.body;

//     // 1. 중복 참여 체크를 트랜잭션 내부로 이동
//     const [participated] = await connection.query(
//       `SELECT 1 FROM survey_responses
//          WHERE survey_id = ? AND user_id = ?`,
//       [surveyId, userId]
//     );

//     if (participated.length > 0) {
//       await connection.rollback(); // 롤백 추가
//       return res.status(400).json({
//         success: false,
//         message: "이미 참여한 설문입니다.",
//       });
//     }

//     try {
//       // 2. 응답 저장
//       await connection.query(
//         `INSERT INTO survey_responses (survey_id, user_id, response_data)
//            VALUES (?, ?, ?)`,
//         [surveyId, userId, JSON.stringify(responses)]
//       );

//       // 3. 설문 응답 수 증가
//       await connection.query(
//         `UPDATE surveys
//            SET current_responses = current_responses + 1
//            WHERE id = ?`,
//         [surveyId]
//       );

//       // 4. 통계 업데이트
//       const statsData = await updateSurveyStats(surveyId, responses);

//       // 5. 포인트 지급
//       const [surveyInfo] = await connection.query(
//         "SELECT reward_amount FROM surveys WHERE id = ?",
//         [surveyId]
//       );

//       await connection.query(
//         `UPDATE user_points
//            SET current_points = current_points + ?
//            WHERE user_id = ?`,
//         [surveyInfo[0].reward_amount, userId]
//       );

//       // 6. 포인트 히스토리 기록
//       await connection.query(
//         `INSERT INTO point_histories (user_id, points, title, type)
//            VALUES (?, ?, ?, 'earn')`,
//         [userId, surveyInfo[0].reward_amount, "설문 참여 보상"]
//       );

//       // 모든 작업이 성공하면 커밋
//       await connection.commit();

//       res.status(200).json({
//         success: true,
//         message: "설문 참여가 완료되었습니다.",
//         points: {
//           earned: surveyInfo[0].reward_amount,
//         },
//       });
//     } catch (error) {
//       // 에러 발생 시 롤백
//       await connection.rollback();
//       throw error;
//     }
//   } catch (error) {
//     console.error("Survey participation error:", error);
//     // 이미 롤백되지 않은 경우에만 롤백
//     if (!connection.isReleased()) {
//       await connection.rollback();
//     }
//     res.status(500).json({
//       success: false,
//       message: "참여 처리 중 오류가 발생했습니다.",
//       error: error.message,
//     });
//   } finally {
//     connection.release();
//   }
// });

app.post("/surveys/:surveyId/participate", async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const surveyId = parseInt(req.params.surveyId);
    const { userId, responses } = req.body;

    // 1. 중복 참여 체크
    const [participated] = await connection.query(
      `SELECT 1 FROM survey_responses 
           WHERE survey_id = ? AND user_id = ?`,
      [surveyId, userId]
    );

    if (participated.length > 0) {
      await connection.rollback();
      return res.status(400).json({
        success: false,
        message: "이미 참여한 설문입니다.",
      });
    }

    // 2. 응답 저장
    await connection.query(
      `INSERT INTO survey_responses (survey_id, user_id, response_data) 
           VALUES (?, ?, ?)`,
      [surveyId, userId, JSON.stringify(responses)]
    );

    // 3. 설문 응답 수 증가
    await connection.query(
      `UPDATE surveys 
           SET current_responses = current_responses + 1 
           WHERE id = ?`,
      [surveyId]
    );

    // 4. 통계 업데이트
    let statsData = {};
    try {
      // 현재 통계 존재 여부 확인
      const [existingStats] = await connection.query(
        `SELECT * FROM survey_statistics WHERE survey_id = ?`,
        [surveyId]
      );

      const [currentResponses] = await connection.query(
        `SELECT current_responses FROM surveys WHERE id = ?`,
        [surveyId]
      );

      // 응답 데이터 집계
      Object.entries(responses).forEach(([questionId, answers]) => {
        if (!statsData[questionId]) {
          statsData[questionId] = { responses: {} };
        }

        if (Array.isArray(answers)) {
          answers.forEach((answer) => {
            statsData[questionId].responses[answer] =
              (statsData[questionId].responses[answer] || 0) + 1;
          });
        }
      });

      if (!existingStats.length) {
        // 통계 데이터가 없으면 새로 생성
        await connection.query(
          `INSERT INTO survey_statistics 
       (survey_id, total_responses, statistics_data, last_updated)
       VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
          [
            surveyId,
            currentResponses[0].current_responses,
            JSON.stringify(statsData),
          ]
        );
      } else {
        // 있으면 업데이트
        await connection.query(
          `UPDATE survey_statistics 
       SET total_responses = ?,
           statistics_data = ?,
           last_updated = CURRENT_TIMESTAMP
       WHERE survey_id = ?`,
          [
            currentResponses[0].current_responses,
            JSON.stringify(statsData),
            surveyId,
          ]
        );
      }
    } catch (statsError) {
      console.error("Statistics update error:", statsError);
      // 통계 업데이트 실패해도 다른 처리는 계속 진행
    }

    // 5. 포인트 지급
    const [surveyInfo] = await connection.query(
      "SELECT reward_amount FROM surveys WHERE id = ?",
      [surveyId]
    );

    await connection.query(
      `UPDATE user_points 
           SET current_points = current_points + ? 
           WHERE user_id = ?`,
      [surveyInfo[0].reward_amount, userId]
    );

    // 6. 포인트 히스토리 기록
    await connection.query(
      `INSERT INTO point_histories (user_id, points, title, type) 
           VALUES (?, ?, ?, 'earn')`,
      [userId, surveyInfo[0].reward_amount, "설문 참여 보상"]
    );

    await connection.commit();

    res.status(200).json({
      success: true,
      message: "설문 참여가 완료되었습니다.",
      points: {
        earned: surveyInfo[0].reward_amount,
      },
    });
  } catch (error) {
    await connection.rollback();
    console.error("Survey participation error:", error);
    res.status(500).json({
      success: false,
      message: "참여 처리 중 오류가 발생했습니다.",
      error: error.message,
    });
  } finally {
    connection.release();
  }
});

// 전체 설문 목록 조회 API 수정
app.get("/surveys", async (req, res) => {
  try {
    const surveys = await getAllSurveys();
    res.json(surveys);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "설문 목록을 불러오는데 실패했습니다.",
    });
  }
});

// 개별 설문 조회 API 수정
app.get("/survey/:id", async (req, res) => {
  try {
    const [survey] = await pool.query(
      `SELECT s.*, u.name as creator_name
         FROM surveys s
         LEFT JOIN users u ON s.creator_id = u.id
         WHERE s.id = ?`,
      [req.params.id]
    );

    if (!survey.length) {
      return res.status(404).json({
        success: false,
        message: "설문을 찾을 수 없습니다.",
      });
    }

    res.json(survey[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "설문을 불러오는데 실패했습니다.",
    });
  }
});

app.get("/survey/:id/stats", async (req, res) => {
  const connection = await pool.getConnection();
  try {
    // surveys와 survey_statistics 조인하여 데이터 조회
    const [stats] = await connection.query(
      `SELECT s.id, s.title, s.reward_amount, 
                COALESCE(ss.total_responses, 0) as total_responses,
                COALESCE(ss.statistics_data, '{}') as statistics_data,
                COALESCE(ss.last_updated, NOW()) as last_updated
         FROM surveys s
         LEFT JOIN survey_statistics ss ON s.id = ss.survey_id
         WHERE s.id = ?`,
      [req.params.id]
    );

    if (!stats.length) {
      return res.status(404).json({
        success: false,
        message: "설문을 찾을 수 없습니다.",
      });
    }

    // 통계 데이터 파싱
    const statisticsData =
      typeof stats[0].statistics_data === "string"
        ? JSON.parse(stats[0].statistics_data)
        : stats[0].statistics_data;

    const responseData = {
      success: true,
      surveyId: parseInt(req.params.id),
      title: stats[0].title,
      totalResponses: parseInt(stats[0].total_responses),
      rewardAmount: stats[0].reward_amount,
      summary: {
        totalResponses: parseInt(stats[0].total_responses),
        lastUpdated: stats[0].last_updated,
      },
      questions: statisticsData,
    };

    console.log("Stats response data:", responseData); // 디버깅용
    res.json(responseData);
  } catch (error) {
    console.error("Error loading survey statistics:", error);
    res.status(500).json({
      success: false,
      message: "통계를 불러오는데 실패했습니다.",
      error: error.message,
    });
  } finally {
    connection.release();
  }
});

// 사용자별 생성한 설문 목록 조회 API 수정
app.get("/users/:userId/surveys", async (req, res) => {
  try {
    const [surveys] = await pool.query(
      `SELECT s.*, 
          COUNT(sr.id) as response_count
         FROM surveys s
         LEFT JOIN survey_responses sr ON s.id = sr.survey_id
         WHERE s.creator_id = ?
         GROUP BY s.id`,
      [req.params.userId]
    );

    res.json(surveys);
  } catch (error) {
    console.error("Error loading user surveys:", error);
    res.status(500).json({
      success: false,
      message: "설문 목록을 불러오는데 실패했습니다.",
    });
  }
});

// 사용자 활동 내역 조회 API 수정
app.get("/users/:userId/activities", async (req, res) => {
  try {
    // 참여한 설문 목록 조회
    const [participated] = await pool.query(
      `SELECT sr.survey_id, sr.created_at as participated_at,
                s.title as survey_title, sr.response_data
         FROM survey_responses sr
         JOIN surveys s ON sr.survey_id = s.id
         WHERE sr.user_id = ?`,
      [req.params.userId]
    );

    // 생성한 설문 목록 조회
    const [created] = await pool.query(
      `SELECT id as survey_id, created_at, title
         FROM surveys
         WHERE creator_id = ?`,
      [req.params.userId]
    );

    res.json({
      participated_surveys: participated,
      created_surveys: created,
    });
  } catch (error) {
    console.error("Error fetching user activities:", error);
    res.status(500).json({
      success: false,
      message: "활동 내역을 불러오는데 실패했습니다.",
    });
  }
});

// 포인트 업데이트 함수 수정
async function updateUserPoints(userId, pointChange, title) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 포인트 업데이트
    await connection.query(
      `UPDATE user_points 
         SET current_points = current_points + ? 
         WHERE user_id = ?`,
      [pointChange, userId]
    );

    // 포인트 히스토리 추가
    await connection.query(
      `INSERT INTO point_histories (user_id, points, title, type) 
         VALUES (?, ?, ?, ?)`,
      [userId, Math.abs(pointChange), title, pointChange > 0 ? "earn" : "use"]
    );

    // 현재 포인트 조회
    const [points] = await connection.query(
      "SELECT current_points FROM user_points WHERE user_id = ?",
      [userId]
    );

    await connection.commit();
    return points[0];
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

// 포인트 내역 조회 API 수정
app.get("/users/:userId/points/history", async (req, res) => {
  try {
    const [history] = await pool.query(
      `SELECT id, points, title, type, created_at
         FROM point_histories
         WHERE user_id = ?
         ORDER BY created_at DESC`,
      [req.params.userId]
    );

    res.json(history);
  } catch (error) {
    console.error("Error loading point history:", error);
    res.status(500).json({
      success: false,
      message: "포인트 내역을 불러오는데 실패했습니다.",
      error: error.message,
    });
  }
});

// 현재 포인트 조회 API 수정
app.get("/users/:userId/points/current", async (req, res) => {
  try {
    const [points] = await pool.query(
      "SELECT current_points FROM user_points WHERE user_id = ?",
      [req.params.userId]
    );

    if (!points.length) {
      return res.status(404).json({
        success: false,
        message: "포인트 정보를 찾을 수 없습니다.",
      });
    }

    res.json({
      success: true,
      currentPoints: points[0].current_points,
    });
  } catch (error) {
    console.error("Error loading current points:", error);
    res.status(500).json({
      success: false,
      message: "현재 포인트를 불러오는데 실패했습니다.",
      error: error.message,
    });
  }
});

// 기프티콘 목록 조회 API 수정
app.get("/gifticons", async (req, res) => {
  try {
    const [gifticons] = await pool.query(
      "SELECT * FROM gifticons ORDER BY price ASC"
    );

    res.json(gifticons);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "기프티콘 목록을 불러오는데 실패했습니다.",
    });
  }
});

app.post("/surveys", async (req, res) => {
  try {
    const surveyData = req.body;
    console.log("Creating survey with data:", surveyData);
    console.log("Creator ID:", surveyData.creatorId);

    const newId = await saveSurvey(surveyData);

    res.status(201).json({ success: true, id: newId });
  } catch (error) {
    console.error("Survey creation error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create survey",
      error: error.message,
    });
  }
});

// 루트 경로 추가
app.get("/", (req, res) => {
  res.send("Hello World!");
});

// 서버 시작
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
