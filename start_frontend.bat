@echo off
title Frontend - Quiz Flag
echo Démarrage du frontend Flutter...
cd /d "%~dp0FRONT"
flutter run -d web-server --web-port 3000
pause