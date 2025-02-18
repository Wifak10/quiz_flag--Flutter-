const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const {getUserByEmail , createUser } = require('../models/user.model');

//Route pour l'inscription
Router.post('/register',(req,res)=>{
    const {username,email,password,avatar} = req.body;
    //Vérifier si l'email existe déjà
    getUserByEmail(email,(err,user)=>{
        if(err){
            return res.status(500).send('Erreur serveur');
        }
        if(user){
            return res.status(400).send('Cet email existe déjà');
        }
        //Hashage du mot de passe avant de l'enregistrer
        bcrypt.hash(password,10,(err,hasedPassword)=>{
            if(err){
                return res.status(500).send('Erreur lors du hashage du mot de passe');
            }

            //Créer l'utilisateur dans la base de données
            createUser(username,email, hasedPassword, avatar,(err,result)=>{
                if(err){
                    return res.status(500).send("Erreur lors de l'inscription");
                }
                res.status(201).send('Utilisateur créé avec succès');
            });
        });
    });
});

//Route pour la connexion
Router.post('/login',(req,res)=>{
    const {email, password} = req.body;
    //Vérifier si l'utilisateur existe déjà
    if (err) {
        return res.status(500).send('Erreur serveur');
        
    }
})
module.exports = Router;