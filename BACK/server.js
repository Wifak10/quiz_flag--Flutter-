const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth.routes'); // Assurez-vous d'importer correctement les routes d'authentification
const scoreRoutes = require('./routes/score.routes'); // Assurez-vous d'importer correctement les routes de score
const leaderboardRoutes = require('./routes/leaderboard.routes'); // Importez les routes de leaderboard
const profileRoutes = require('./routes/profile.routes'); // Importez les routes de profil
require('dotenv').config();
const app = express();
const cors = require('cors');
app.use(cors());

app.use(bodyParser.json());
app.use('/api/auth', authRoutes); // Utilisez '/api/auth' pour les routes d'authentification
app.use('/api/score', scoreRoutes); // Utilisez '/api/score' pour les routes de score
app.use('/api/leaderboard', leaderboardRoutes); // Utilisez '/api/leaderboard' pour les routes de leaderboard
app.use('/api/profile', profileRoutes); // Utilisez '/api/profile' pour les routes de profil

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});