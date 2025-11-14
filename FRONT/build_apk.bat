@echo off
echo ========================================
echo    CONSTRUCTION DE L'APK QUIZ FLAGS
echo ========================================
echo.

echo Nettoyage des fichiers de build precedents...
flutter clean

echo.
echo Installation des dependances...
flutter pub get

echo.
echo Generation des icones d'application...
flutter pub run flutter_launcher_icons:main

echo.
echo Verification de la configuration Android...
cd android
call gradlew clean
cd ..

echo.
echo Construction de l'APK en mode release...
flutter build apk --release --split-per-abi

echo.
echo Construction de l'APK universel...
flutter build apk --release

echo.
echo ========================================
echo           BUILD TERMINE !
echo ========================================
echo.
echo Les APK ont ete generes dans :
echo - build\app\outputs\flutter-apk\app-release.apk (universel)
echo - build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo - build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
echo - build\app\outputs\flutter-apk\app-x86_64-release.apk
echo.

echo Ouverture du dossier de sortie...
start build\app\outputs\flutter-apk\

pause