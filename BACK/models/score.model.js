const db = require('../config/db');

// Fonction pour créer un score
const createScore = (userId, score, callback) => {
  const query = 'INSERT INTO scores (user_id, score) VALUES (?, ?)';

  console.log('Exécution de la requête pour insérer un score:', { userId, score });

  db.query(query, [userId, score], (err, result) => {
    if (err) {
      console.error('Erreur lors de l\'insertion du score:', err.message);
      return callback(err); // Retourner l'erreur au callback
    }
    console.log('Score inséré avec succès:', result);
    callback(null, result); // Passer le résultat au callback
  });
};

// Fonction pour récupérer les scores d'un utilisateur
const getUserScores = (userId, callback) => {
  const query = 'SELECT score, game_date FROM scores WHERE user_id = ? ORDER BY game_date DESC';

  console.log('Exécution de la requête pour récupérer les scores de l\'utilisateur:', userId);

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des scores:', err.message);
      return callback(err);
    }
    console.log('Scores récupérés:', results);
    callback(null, results); // Passer les résultats au callback
  });
};

// Fonction pour récupérer le leaderboard
const getLeaderboard = (callback) => {
  const query = 'SELECT u.username, MAX(s.score) AS score FROM users u JOIN scores s ON u.id = s.user_id GROUP BY u.id ORDER BY score DESC LIMIT 10';

  console.log('Exécution de la requête pour récupérer le leaderboard');

  db.query(query, callback);
};

module.exports = { createScore, getUserScores, getLeaderboard };
