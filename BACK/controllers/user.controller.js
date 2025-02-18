const db = require('../config/db');
const { getUserByEmail, createUser } = require('../models/user.model');
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 10;

const registerUser = (req, res) => {
    const { username, email, password, avatar } = req.body;

    getUserByEmail(email, (err, user) => {
        if (err) return res.status(500).json({ error: 'Erreur serveur' });

        if (user) {
            return res.status(400).json({ message: "Cet email existe déjà" });
        }

        bcrypt.hash(password, SALT_ROUNDS, (err, hash) => {
            if (err) return res.status(500).json({ error: "Erreur lors du hachage du mot de passe" });

            createUser(username, email, hash, avatar, (err, result) => {
                if (err) return res.status(500).json({ error: "Erreur lors de l'inscription" });

                res.status(201).json({ message: "Utilisateur inscrit avec succès", userId: result.insertId });
            });
        });
    });
};

// 🚀 S'assurer que l'export est correct
module.exports = { registerUser };
