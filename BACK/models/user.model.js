const db = require('../config/db');

// Fonction pour récupérer le profil de l'utilisateur
const getUserProfile = (userId, callback) => {
  const query = 'SELECT id, username, email, avatar_url FROM users WHERE id = ?';

  console.log('Exécution de la requête pour récupérer le profil de l\'utilisateur:', userId);

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération du profil:', err.message);
      return callback(err);
    }
    console.log('Profil récupéré:', results[0]);
    callback(null, results[0]); // Passer le profil au callback
  });
};

// Fonction pour mettre à jour le profil de l'utilisateur
const updateUserProfile = (userId, { username, email, avatarUrl }, callback) => {
  const query = 'UPDATE users SET username = ?, email = ?, avatar_url = ? WHERE id = ?';

  console.log('Exécution de la requête pour mettre à jour le profil de l\'utilisateur:', { userId, username, email, avatarUrl });

  db.query(query, [username, email, avatarUrl, userId], (err, result) => {
    if (err) {
      console.error('Erreur lors de la mise à jour du profil:', err.message);
      return callback(err);
    }
    console.log('Profil mis à jour avec succès:', result);
    getUserProfile(userId, callback); // Récupérer le profil mis à jour
  });
};

module.exports = { getUserProfile, updateUserProfile };