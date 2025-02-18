const express = require('express');
const { registerUser } = require('../controllers/user.controller'); // Correction du chemin
const router = express.Router();

router.post('/register', registerUser); // Utiliser la fonction correcte

module.exports = router;
