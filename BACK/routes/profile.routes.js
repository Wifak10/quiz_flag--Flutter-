const express = require('express');
const router = express.Router();
const db = require('../config/db'); // Assurez-vous que le chemin est correct
const jwt = require('jsonwebtoken');
require('dotenv').config();

// Middleware pour vérifier le token JWT
const authenticateToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.sendStatus(401);

  jwt.verify(token.split(' ')[1], process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// Endpoint pour récupérer le profil utilisateur
router.get('/', authenticateToken, (req, res) => {
  db.query('SELECT email, username FROM users WHERE id = ?', [req.user.userId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(400).send('Utilisateur non trouvé');
    }
    res.json(results[0]);
  });
});

// Endpoint pour mettre à jour le profil utilisateur
router.put('/', authenticateToken, (req, res) => {
  const { email, username } = req.body;
  db.query('UPDATE users SET email = ?, username = ? WHERE id = ?', [email, username, req.user.userId], (err, result) => {
    if (err) {
      return res.status(500).send('Erreur lors de la mise à jour du profil');
    }
    res.send('Profil mis à jour');
  });
});

module.exports = router;