const express = require('express');
const {getLeaderboard} = require('../models/score.model');
const Router = express.Router();

//Route pour récupérer le leaderboard
Router.get('/leaderboard',(req, res)=>{
    getLeaderboard((err,results)=>{
        if (err) {
            return res.status(500).send('Erreur lors de la récupération du leaderboard');    
        }
        res.status(200).json(results); //Cela renvoie les meilleurs scores
    })
})
module.exports = Router ;