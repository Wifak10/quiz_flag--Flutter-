const express = require('express');
const { createUser, getUserByEmail } = require('../models/user.model');  // Vérifie que le chemin est correct
const router = express.Router();

// Exemple de route pour l'inscription (à ajuster selon ton besoin)
router.post('/register', (req, res) => {
  const { username, email, password, avatar } = req.body;

  // Vérifier si l'utilisateur existe déjà
  getUserByEmail(email, (err, user) => {
    if (err) {
      return res.status(500).send('Erreur serveur');
    }
    if (user) {
      return res.status(400).send('Cet email existe déjà');
    }

    // Création de l'utilisateur
    createUser(username, email, password, avatar, (err, result) => {
      if (err) {
        return res.status(500).send("Erreur lors de la création de l'utilisateur");
      }
      res.status(201).send('Utilisateur créé avec succès');
    });
  });
});

module.exports = router;
