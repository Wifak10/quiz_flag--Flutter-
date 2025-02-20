const express = require('express');
const { createScore, getUserScores } = require('../models/score.model'); // Utilise le bon modèle
const router = express.Router();

// Route pour soumettre un score
router.post('/', (req, res) => {
  const { userId, score } = req.body;

  console.log(`Requête reçue pour soumettre un score: userId=${userId}, score=${score}`);

  // Vérification simple si les données sont présentes
  if (!userId || !score) {
    return res.status(400).send('userId et score sont requis');
  }

  // Créer un score dans la base de données
  createScore(userId, score, (err, result) => {
    if (err) {
      console.error('Erreur lors de la soumission du score:', err.message);
      return res.status(500).send('Erreur lors de la soumission du score');
    }
    console.log('Score enregistré avec succès:', result);
    res.status(201).send('Score enregistré');
  });
});

// Route pour récupérer les scores d'un utilisateur
router.get('/user-scores/:userId', (req, res) => {
  const { userId } = req.params;

  console.log(`Requête reçue pour récupérer les scores de l'utilisateur avec ID: ${userId}`);

  // Récupérer les scores de l'utilisateur
  getUserScores(userId, (err, scores) => {
    if (err) {
      console.error('Erreur lors de la récupération des scores:', err.message);
      return res.status(500).send('Erreur lors de la récupération des scores');
    }
    console.log('Scores récupérés:', scores);
    res.status(200).json(scores); // Renvoie les scores de l'utilisateur
  });
});

module.exports = router;