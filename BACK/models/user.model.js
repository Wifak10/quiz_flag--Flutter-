const db = require('../config/db');

const getUserByEmail = (email, callback) => {
    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
        if (err) return callback(err, null);
        callback(null, results.length > 0 ? results[0] : null);
    });
};

const createUser = (username, email, password, avatar, callback) => {
    const query = 'INSERT INTO users (username, email, password, avatar) VALUES (?, ?, ?, ?)';
    db.query(query, [username, email, password, avatar], callback);
};

module.exports = { getUserByEmail, createUser };
