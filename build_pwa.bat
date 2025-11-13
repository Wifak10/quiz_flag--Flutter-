@echo off
echo Construction de la PWA Quiz Flag...
echo.

cd /d "c:\Users\adechina.ayekpola\Documents\DOSSIER\DOSSIER\DEV-PROJET\quiz_flag--Flutter-\FRONT"

echo Nettoyage des fichiers de build precedents...
flutter clean

echo Installation des dependances...
flutter pub get

echo Construction de l'application web...
flutter build web --release --web-renderer html

echo.
echo ✅ Build terminé !
echo.
echo Les fichiers PWA sont dans : build\web\
echo.
echo Pour tester localement :
echo 1. Installez un serveur HTTP simple : npm install -g http-server
echo 2. Naviguez vers build\web\ : cd build\web
echo 3. Lancez le serveur : http-server -p 8080
echo 4. Ouvrez http://localhost:8080 dans votre navigateur
echo.
echo Pour déployer sur Netlify :
echo 1. Glissez-déposez le dossier build\web\ sur https://app.netlify.com/drop
echo 2. Ou utilisez Netlify CLI : netlify deploy --prod --dir=build\web
echo.
pause