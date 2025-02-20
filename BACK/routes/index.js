const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const profileRoutes = require('./profile.routes');
const scoreRoutes = require('./score.routes');

router.use('/auth', authRoutes);
router.use('/profile', profileRoutes);
router.use('/score', scoreRoutes);

module.exports = router;