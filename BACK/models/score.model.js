const db = require('../config/db'); // Importer la connexion à la base de données

// Fonction pour créer un score
const createScore = (userId, score, callback) => {
  const query = 'INSERT INTO scores (user_id, score) VALUES (?, ?)';
  db.query(query, [userId, score], callback);
};

// Fonction pour récupérer les scores d'un utilisateur
const getUserScores = (userId, callback) => {
  const query = 'SELECT score, game_date FROM scores WHERE user_id = ? ORDER BY game_date DESC';
  db.query(query, [userId], callback);
};

// Fonction pour récupérer le leaderboard
const getLeaderboard = (callback) => {
  const query = 'SELECT u.username, MAX(s.score) AS score FROM users u JOIN scores s ON u.id = s.user_id GROUP BY u.id ORDER BY score DESC LIMIT 10';
  db.query(query, callback);
};

module.exports = { createScore, getUserScores, getLeaderboard };
