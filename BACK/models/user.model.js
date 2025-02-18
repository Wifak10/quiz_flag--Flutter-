const db = require('../config/db'); // Importer la connexion à la base de données

// Fonction pour créer un utilisateur
const createUser = (username, email, password, avatar, callback) => {
  const query = 'INSERT INTO users (username, email, password, avatar) VALUES (?, ?, ?, ?)';
  db.query(query, [username, email, password, avatar], callback);
};

// Fonction pour récupérer un utilisateur par son email
const getUserByEmail = (email, callback) => {
  const query = 'SELECT * FROM users WHERE email = ?';
  db.query(query, [email], callback);
};

// Fonction pour récupérer un utilisateur par son id
const getUserById = (id, callback) => {
  const query = 'SELECT * FROM users WHERE id = ?';
  db.query(query, [id], callback);
};

// Fonction pour mettre à jour un utilisateur
const updateUser = (id, username, email, avatar, callback) => {
  const query = 'UPDATE users SET username = ?, email = ?, avatar = ? WHERE id = ?';
  db.query(query, [username, email, avatar, id], callback);
};

module.exports = { createUser, getUserByEmail, getUserById, updateUser };
