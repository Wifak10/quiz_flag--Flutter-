const db = require('../config/db');
const { getUserByEmail, createUser } = require('../models/user.model');

const registerUser = (req, res) => {
    const { username, email, password, avatar } = req.body;

    getUserByEmail(email, (err, user) => {
        if (err) return res.status(500).json({ error: 'Erreur serveur' });

        if (user) {
            return res.status(400).json({ message: "Cet email existe déjà" });
        }

        createUser(username, email, password, avatar, (err, result) => {
            if (err) return res.status(500).json({ error: "Erreur lors de l'inscription" });

            res.status(201).json({ message: "Utilisateur inscrit avec succès", userId: result.insertId });
        });
    });
};

module.exports = { registerUser };
