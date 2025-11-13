@echo off
title Backend - Quiz Flag
echo Démarrage du backend Quiz Flag...
cd /d "%~dp0"
call npm install
cd BACK
node server.js
pause