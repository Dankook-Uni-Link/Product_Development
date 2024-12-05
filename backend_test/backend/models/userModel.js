const db = require('./db');

exports.createUser = (username, hashedPassword, email, gender, birthdate, callback) => {
    const query = `
        INSERT INTO users (username, password, email, gender, birthdate)
        VALUES (?, ?, ?, ?, ?)
    `;
    db.query(query, [username, hashedPassword, email, gender, birthdate], callback);
};

exports.findUserByUsername = (username, callback) => {
    const query = 'SELECT * FROM users WHERE username = ?';
    db.query(query, [username], callback);
};