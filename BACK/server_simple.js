const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Données temporaires en mémoire (remplace la DB)
let users = [];
let scores = [];
let currentId = 1;

// Routes de base
app.get('/', (req, res) => {
  res.json({ message: 'Quiz Flag API - Serveur actif!' });
});

// Auth routes simplifiées
app.post('/api/auth/register', (req, res) => {
  const { username, email, password } = req.body;
  const user = { id: currentId++, username, email, password };
  users.push(user);
  res.json({ success: true, message: 'Utilisateur créé', userId: user.id });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (user) {
    res.json({ success: true, token: 'fake-token', user: { id: user.id, username: user.username } });
  } else {
    res.status(401).json({ success: false, message: 'Identifiants incorrects' });
  }
});

// Score routes
app.post('/api/score/save', (req, res) => {
  const { userId, score, level } = req.body;
  scores.push({ id: currentId++, userId, score, level, date: new Date() });
  res.json({ success: true, message: 'Score sauvegardé' });
});

app.get('/api/leaderboard', (req, res) => {
  const leaderboard = scores
    .sort((a, b) => b.score - a.score)
    .slice(0, 10)
    .map(s => ({
      username: users.find(u => u.id === s.userId)?.username || 'Anonyme',
      score: s.score,
      level: s.level
    }));
  res.json(leaderboard);
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`✅ Serveur Quiz Flag démarré sur le port ${PORT}`);
  console.log(`🌐 API disponible sur: http://localhost:${PORT}`);
  console.log(`📊 Test: http://localhost:${PORT}/api/leaderboard`);
});