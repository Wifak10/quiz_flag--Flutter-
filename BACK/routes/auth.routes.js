const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { getUserByEmail, createUser } = require('../models/user.model');
const router = express.Router(); // Utilise `router` en minuscule

// Route pour l'inscription
router.post('/register', (req, res) => {
    const { username, email, password, avatar } = req.body;
    // Vérifier si l'email existe déjà
    getUserByEmail(email, (err, user) => {
        if (err) {
            return res.status(500).send('Erreur serveur');
        }
        if (user) {
            return res.status(400).send('Cet email existe déjà');
        }
        // Hashage du mot de passe avant de l'enregistrer
        bcrypt.hash(password, 10, (err, hasedPassword) => {
            if (err) {
                return res.status(500).send('Erreur lors du hashage du mot de passe');
            }

            // Créer l'utilisateur dans la base de données
            createUser(username, email, hasedPassword, avatar, (err, result) => {
                if (err) {
                    return res.status(500).send("Erreur lors de l'inscription");
                }
                res.status(201).send('Utilisateur créé avec succès');
            });
        });
    });
});

// Route pour la connexion
router.post('/login', (req, res) => {
    const { email, password } = req.body;
    // Vérifier si l'utilisateur existe déjà
    getUserByEmail(email, (err, user) => {
        if (err) {
            return res.status(500).send('Erreur serveur');
        }
        if (!user) {
            return res.status(400).send('Utilisateur non trouvé');
        }
        // Vérifier si le mot de passe est correct
        bcrypt.compare(password, user.password, (err, isMatch) => {
            if (err) {
                return res.status(500).send('Erreur de vérification du mot de passe');
            }
            if (!isMatch) {
                return res.status(400).send('Mot de passe incorrect');
            }

            // Générer un token JWT
            const token = jwt.sign({ userId: user.id }, 'secretKey', { expiresIn: '4h' });
            res.status(200).json({ token });
        });
    });
});

module.exports = router; // Assurez-vous que l'export utilise `router`
