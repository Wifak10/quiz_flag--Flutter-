const express = require('express');
const { createScore, getUserScores } = require('../models/scoreModel');
const router = express.Router();

// Route pour soumettre un score
router.post('/score', (req, res) => {
  const { userId, score } = req.body;

  // Créer un score dans la base de données
  createScore(userId, score, (err, result) => {
    if (err) {
      return res.status(500).send('Erreur lors de la soumission du score');
    }
    res.status(201).send('Score enregistré');
  });
});

// Route pour récupérer les scores d'un utilisateur
router.get('/user-scores/:userId', (req, res) => {
  const { userId } = req.params;

  // Récupérer les scores de l'utilisateur
  getUserScores(userId, (err, scores) => {
    if (err) {
      return res.status(500).send('Erreur lors de la récupération des scores');
    }
    res.status(200).json(scores); // Renvoie les scores de l'utilisateur
  });
});

module.exports = router;
