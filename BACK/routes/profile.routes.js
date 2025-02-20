const express = require('express');
const { getUserProfile, updateUserProfile } = require('../models/user.model');
const router = express.Router();

// Route pour récupérer le profil de l'utilisateur
router.get('/profile', (req, res) => {
  const userId = req.user.id; // Assurez-vous que l'utilisateur est authentifié et que l'ID de l'utilisateur est disponible

  getUserProfile(userId, (err, profile) => {
    if (err) {
      return res.status(500).send('Erreur lors de la récupération du profil');
    }
    res.status(200).json(profile);
  });
});

// Route pour mettre à jour le profil de l'utilisateur
router.put('/profile', (req, res) => {
  const userId = req.user.id; // Assurez-vous que l'utilisateur est authentifié et que l'ID de l'utilisateur est disponible
  const { username, email, avatarUrl } = req.body;

  updateUserProfile(userId, { username, email, avatarUrl }, (err, profile) => {
    if (err) {
      return res.status(500).send('Erreur lors de la mise à jour du profil');
    }
    res.status(200).json(profile);
  });
});

module.exports = router;