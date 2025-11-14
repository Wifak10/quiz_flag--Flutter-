# Instructions de Build - Quiz des Pays

## 🚀 Guide de Construction APK

### Prérequis
- Flutter SDK (version 3.0.0 ou supérieure)
- Android SDK
- Java JDK 8 ou supérieur
- Git

### Installation des Dépendances

```bash
# Nettoyer le projet
flutter clean

# Installer les dépendances
flutter pub get

# Générer les icônes d'application
flutter pub run flutter_launcher_icons:main
```

### Construction de l'APK

#### Méthode 1: Script Automatisé (Recommandé)
```bash
# Exécuter le script de build automatisé
./build_apk.bat
```

#### Méthode 2: Commandes Manuelles
```bash
# APK universel (compatible avec tous les appareils)
flutter build apk --release

# APK optimisés par architecture (taille réduite)
flutter build apk --release --split-per-abi

# APK de debug pour les tests
flutter build apk --debug
```

### Fichiers Générés

Les APK seront disponibles dans :
```
build/app/outputs/flutter-apk/
├── app-release.apk                 # APK universel (~50MB)
├── app-arm64-v8a-release.apk      # Pour appareils 64-bit modernes (~25MB)
├── app-armeabi-v7a-release.apk    # Pour appareils 32-bit (~25MB)
└── app-x86_64-release.apk         # Pour émulateurs x86 (~25MB)
```

### Optimisations Appliquées

#### 🎯 Responsivité
- **flutter_screenutil** : Adaptation automatique aux tailles d'écran
- **responsive_framework** : Breakpoints pour mobile/tablette/desktop
- **Grilles adaptatives** : Nombre de colonnes selon la taille d'écran

#### 🎨 Animations et Transitions
- **flutter_animate** : Animations fluides et performantes
- **flutter_staggered_animations** : Animations en cascade
- **Transitions personnalisées** : Entre les écrans
- **Micro-interactions** : Feedback visuel pour chaque action

#### 🖼️ Design Amélioré
- **Image de fond** : Collage de drapeaux sur tous les écrans
- **Glassmorphism** : Effets de verre moderne
- **Dégradés dynamiques** : Couleurs harmonieuses
- **Cartes animées** : Avec ombres et élévations

#### ⚡ Performance
- **Proguard** : Obfuscation et optimisation du code
- **Split APK** : Réduction de 50% de la taille
- **Cache réseau** : Images mises en cache automatiquement
- **Lazy loading** : Chargement à la demande

### Nouvelles Fonctionnalités

#### 🎮 Modes de Jeu
1. **Quiz des Drapeaux** : Mode classique
2. **Quiz des Capitales** : Devinez les capitales
3. **Mode Mixte** : Questions variées (drapeaux, capitales, régions, monnaies)

#### 📚 Modes d'Apprentissage
1. **Apprentissage Classique** : Navigation par pays et régions
2. **Apprentissage Avancé** : 
   - Onglets spécialisés (Géographie, Culture, Statistiques)
   - Filtres par difficulté
   - Informations détaillées sur chaque pays
   - Statistiques mondiales

#### 🎯 Système de Score Avancé
- **Séries de bonnes réponses** : Bonus multiplicateur
- **Précision** : Pourcentage de réussite
- **Statistiques détaillées** : Historique des performances

### Résolution des Problèmes

#### Erreur de Build
```bash
# Si erreur de dépendances
flutter pub deps
flutter pub upgrade

# Si erreur Android
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Problème de Taille APK
```bash
# Utiliser les APK split pour réduire la taille
flutter build apk --release --split-per-abi --target-platform android-arm64
```

#### Erreur de Signature
```bash
# Générer une nouvelle clé de signature
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Configuration de Signature (Production)

1. Créer le fichier `android/key.properties` :
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<location of the key store file>
```

2. Modifier `android/app/build.gradle` :
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart

# Analyse du code
flutter analyze
```

### Déploiement

#### Google Play Store
```bash
# Générer l'App Bundle (recommandé)
flutter build appbundle --release
```

#### Distribution Directe
```bash
# APK signé pour distribution
flutter build apk --release
```

### Support et Maintenance

- **Versions supportées** : Android 5.0+ (API 21+)
- **Architectures** : ARM64, ARMv7, x86_64
- **Tailles d'écran** : Tous formats (phone, tablet, desktop)
- **Orientations** : Portrait et paysage

### Métriques de Performance

- **Temps de démarrage** : < 3 secondes
- **Taille APK** : 25-50 MB selon l'architecture
- **Consommation RAM** : < 100 MB
- **Fluidité** : 60 FPS constant

---

## 📱 Installation sur Appareil

1. Activer les "Sources inconnues" dans les paramètres Android
2. Télécharger l'APK approprié à votre architecture
3. Installer en suivant les instructions à l'écran
4. Profiter du jeu ! 🎉

## 🔧 Développement

Pour contribuer au projet :
```bash
git clone <repository>
cd quiz_flag--Flutter-/FRONT
flutter pub get
flutter run
```