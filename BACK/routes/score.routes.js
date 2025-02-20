const express = require('express');
const { createScore, getUserScores } = require('../models/score.model');  // Utilise le bon modèle
const router = express.Router();

// Route pour soumettre un score
router.post('/', (req, res) => { // Changer '/score' par '/' ici
  const { userId, score } = req.body;

  // Vérification simple si les données sont présentes
  if (!userId || !score) {
    return res.status(400).send('userId et score sont requis');
  }

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