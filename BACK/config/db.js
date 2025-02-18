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