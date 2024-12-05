const bcrypt = require('bcrypt');
const userModel = require('../models/userModel');

exports.registerUser = async (userData) => {
    const { username, password, email, gender, birthdate } = userData;

    const hashedPassword = await bcrypt.hash(password, 10);

    return new Promise((resolve, reject) => {
        userModel.createUser(username, hashedPassword, email, gender, birthdate, (err) => {
            if (err) {
                reject(err);
            } else {
                resolve('User registered successfully');
            }
        });
    });
};

exports.loginUser = (username, password) => {
    return new Promise((resolve, reject) => {
        userModel.findUserByUsername(username, async (err, results) => {
            if (err) {
                reject(err);
            } else if (results.length === 0) {
                reject(new Error('Invalid username or password'));
            } else {
                const user = results[0];
                const isMatch = await bcrypt.compare(password, user.password);
                if (!isMatch) {
                    reject(new Error('Invalid username or password'));
                } else {
                    resolve('Login successful');
                }
            }
        });
    });
};