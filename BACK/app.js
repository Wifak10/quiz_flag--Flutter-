const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth.routes');
const leaderboardRoutes = require('./routes/leaderboard.routes');
const scoreRoutes = require('./routes/score.routes');
const userRoutes = require('./routes/user.routes');

const app = express();
app.use(bodyParser.json()); // Middleware pour analyser les requêtes JSON

// Utilisation des routes
app.use('/api/auth', authRoutes);
app.use('/api', leaderboardRoutes);
app.use('/api', scoreRoutes);
app.use('/api', userRoutes);

const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
});
