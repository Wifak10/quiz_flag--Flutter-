const db = require('../config/db');

// Fonction pour récupérer un utilisateur par email
const getUserByEmail = (email, callback) => {
  const query = 'SELECT * FROM users WHERE email = ?';

  console.log('Exécution de la requête pour récupérer un utilisateur par email:', email);

  db.query(query, [email], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération de l\'utilisateur par email:', err.message);
      return callback(err);
    }
    callback(null, results[0]); // Passer l'utilisateur au callback
  });
};

// Fonction pour créer un utilisateur
const createUser = (username, email, password, avatar, callback) => {
  const query = 'INSERT INTO users (username, email, password, avatar) VALUES (?, ?, ?, ?)';

  console.log('Exécution de la requête pour créer un utilisateur:', { username, email, password, avatar });

  db.query(query, [username, email, password, avatar || null], (err, result) => {
    if (err) {
      console.error('Erreur lors de la création de l\'utilisateur:', err.message);
      return callback(err);
    }
    console.log('Utilisateur créé avec succès:', result);
    callback(null, result);
  });
};

module.exports = { getUserByEmail, createUser };