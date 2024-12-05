const authService = require('../services/authService');

// 회원가입
exports.register = async (req, res) => {
    try {
        const message = await authService.registerUser(req.body);
        res.status(200).json({ status: 'success', message });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ status: 'fail', message: 'Username or email already exists' });
        } else {
            res.status(500).json({ status: 'error', message: error.message });
        }
    }
};

// 로그인
exports.login = async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ status: 'fail', message: 'All fields are required' });
    }

    try {
        const message = await authService.loginUser(username, password);
        res.status(200).json({ status: 'success', message });
    } catch (error) {
        res.status(401).json({ status: 'fail', message: error.message });
    }
};