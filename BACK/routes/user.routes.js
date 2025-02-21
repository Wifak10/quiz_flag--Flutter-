const express = require('express');
const { registerUser } = require('../controllers/user.controller'); // Vérifie que le chemin est correct
const router = express.Router();

router.post('/register', registerUser); // Vérifie que registerUser est bien défini
// router.post('/login', loginUser); // Vérifie que loginUser est bien défini
module.exports = router;
