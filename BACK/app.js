const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth.routes');
const leaderboardRoutes = require('./routes/leaderboard.routes');
const scoreRoutes = require('./routes/score.routes');
const userRoutes = require('./routes/user.routes');

const app = express();
app.use(bodyParser.json()); // Middleware pour analyser les requêtes JSON

// Routes de l'application
app.use('/api/auth', authRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/score', scoreRoutes);  // Les routes pour gérer les scores
app.use('/api/user', userRoutes);    // Les routes pour gérer les utilisateurs

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});
