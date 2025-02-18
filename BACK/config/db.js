const mysql = require('mysql2');
require('dotenv').config();

/**
 * Création de la connexion MySQL.
 * 
 * Les informations d'identification de la base de données sont récupérées à partir des variables d'environnement :
 * - DB_HOST : Hôte de la base de données
 * - DB_USER : Nom d'utilisateur de la base de données
 * - DB_PASSWORD : Mot de passe de l'utilisateur de la base de données
 * - DB_NAME : Nom de la base de données
 */
const connection = mysql.createConnection({
  host: process.env.DB_HOST,      // L'hôte de la base de données
  user: process.env.DB_USER,      // L'utilisateur de la base de données
  password: process.env.DB_PASSWORD,  // Le mot de passe de l'utilisateur
  database: process.env.DB_NAME   // Le nom de la base de données
});

/**
 * Connexion à la base de données MySQL.
 * 
 * Cette fonction tente de se connecter à la base de données MySQL et affiche un message de succès ou une erreur
 * en cas d'échec de la connexion.
 */
connection.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à la base de données :', err);
    return;
  }
  console.log('Connecté à la base de données MySQL');
});

module.exports = connection;
