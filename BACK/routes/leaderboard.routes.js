const express = require('express');
const { getLeaderboard } = require('../models/score.model');
const router = express.Router();

// Route pour récupérer le leaderboard
router.get('/leaderboard', (req, res) => {
  console.log('Requête reçue pour récupérer le leaderboard');

  // Récupérer le leaderboard
  getLeaderboard((err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération du leaderboard:', err.message);
      return res.status(500).send('Erreur lors de la récupération du leaderboard');
    }
    console.log('Leaderboard récupéré:', results);
    res.status(200).json(results); // Renvoie le leaderboard
  });
});

module.exports = router;