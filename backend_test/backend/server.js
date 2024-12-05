const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config();

const authController = require('./controllers/authController');

const app = express();
app.use(bodyParser.json());

// 라우트 정의
app.post('/auth/register', authController.register);
app.post('/auth/login', authController.login);

// 서버 실행
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
