/**
 * Module de configuration de la connexion à la base de données MySQL.
 * 
 * Ce module utilise la bibliothèque `mysql2` pour établir une connexion à une base de données MySQL
 * en utilisant les informations d'identification stockées dans les variables d'environnement.
 * 
 * @module config/db
 * @requires mysql2
 * @requires dotenv/config
 */

 /**
    * Création de la connexion MySQL.
    * 
    * Les informations d'identification de la base de données sont récupérées à partir des variables d'environnement :
    * - `DB_HOST` : Hôte de la base de données
    * - `DB_USER` : Nom d'utilisateur de la base de données
    * - `DB_PASSWORD` : Mot de passe de l'utilisateur de la base de données
    * - `DB_NAME` : Nom de la base de données
    * 
    * @constant {object} connection - Objet de connexion MySQL.
    */

 /**
    * Connexion à la base de données MySQL.
    * 
    * Cette fonction tente de se connecter à la base de données MySQL et affiche un message de succès ou une erreur
    * en cas d'échec de la connexion.
    * 
    * @function
    * @param {function} callback - Fonction de rappel exécutée après la tentative de connexion.
    * @returns {void}
    */
const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
host: process.env.DB_HOST,
user:process.env.DB_USER,
user:process.env.DB_PASSWORD,
user:process.env.DB_NAME

});

connection.connect((err)=>{
    if(err){
        console.error('Erreur de connetion à la base de données :', err);
        return;
}
console.log('Connecté à la base de données Mysql');
});
module.exports = connection;