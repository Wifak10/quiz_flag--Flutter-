@echo off
title Quiz Flag - Démarrage Simple
echo ========================================
echo    QUIZ FLAG - DEMARRAGE RAPIDE
echo ========================================
echo.

echo 1. Démarrage backend simple (sans DB)...
start "Backend Simple" cmd /k "cd /d \"%~dp0BACK\" && node server_simple.js"

echo.
echo 2. Attente...
timeout /t 2 /nobreak > nul

echo.
echo 3. Démarrage frontend Flutter...
start "Frontend Flutter" cmd /k "cd /d \"%~dp0FRONT\" && flutter run -d web-server --web-port 3000"

echo.
echo ✅ Application démarrée !
echo.
echo 📱 Frontend: http://localhost:3000
echo 🔧 Backend:  http://localhost:5000
echo.
pause