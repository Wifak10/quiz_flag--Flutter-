@echo off
title Quiz Flag - Démarrage App
echo ========================================
echo    QUIZ FLAG - DEMARRAGE COMPLET
echo ========================================
echo.

echo 1. Installation des dépendances backend...
cd /d "%~dp0"
call npm install
if %errorlevel% neq 0 (
    echo Erreur lors de l'installation des dépendances
    pause
    exit /b 1
)

echo.
echo 2. Démarrage du backend (port 5000)...
start "Backend - Quiz Flag" cmd /k "cd /d \"%~dp0BACK\" && node server.js"

echo.
echo 3. Attente du démarrage du backend...
timeout /t 3 /nobreak > nul

echo.
echo 4. Démarrage du frontend Flutter...
start "Frontend - Quiz Flag" cmd /k "cd /d \"%~dp0FRONT\" && flutter run -d web-server --web-port 3000"

echo.
echo ✅ Application démarrée !
echo.
echo 📱 Frontend: http://localhost:3000
echo 🔧 Backend:  http://localhost:5000
echo.
echo Appuyez sur une touche pour fermer cette fenêtre...
pause > nul