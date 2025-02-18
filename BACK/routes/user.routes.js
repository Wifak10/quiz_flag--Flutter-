const express = require('express');
const { getUserById, updateUser } = require('../models/userModel');
const router = express.Router();

// Route pour récupérer un profil utilisateur
router.get('/profile/:userId', (req, res) => {
  const { userId } = req.params;

  // Récupérer les informations de l'utilisateur
  getUserById(userId, (err, user) => {
    if (err) {
      return res.status(500).send('Erreur lors de la récupération du profil');
    }
    if (!user) {
      return res.status(404).send('Utilisateur non trouvé');
    }
    res.status(200).json(user); // Renvoie les informations de l'utilisateur
  });
});

// Route pour mettre à jour le profil utilisateur
router.put('/profile/:userId', (req, res) => {
  const { userId } = req.params;
  const { username, email, avatar } = req.body;

  // Mettre à jour le profil de l'utilisateur
  updateUser(userId, username, email, avatar, (err, result) => {
    if (err) {
      return res.status(500).send('Erreur lors de la mise à jour du profil');
    }
    res.status(200).send('Profil mis à jour avec succès');
  });
});

module.exports = router;
