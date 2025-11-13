# Guide de Déploiement - Quiz des Pays PWA

## 🚀 Déploiement sur Netlify (Recommandé)

### Étape 1: Préparer l'application
```bash
# Installer les dépendances
flutter pub get

# Build pour le web
flutter build web --release
```

### Étape 2: Déployer sur Netlify

#### Option A: Via l'interface Netlify
1. Créez un compte sur [Netlify](https://www.netlify.com/)
2. Cliquez sur "Add new site" > "Deploy manually"
3. Glissez-déposez le dossier `build/web`
4. Votre site sera disponible sur `https://votre-site.netlify.app`

#### Option B: Via Netlify CLI
```bash
# Installer Netlify CLI
npm install -g netlify-cli

# Se connecter
netlify login

# Déployer
cd build/web
netlify deploy --prod
```

### Étape 3: Configuration PWA sur Netlify

Créez un fichier `netlify.toml` à la racine du projet:

```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[headers]]
  for = "/manifest.json"
  [headers.values]
    Content-Type = "application/manifest+json"

[[headers]]
  for = "/sw.js"
  [headers.values]
    Content-Type = "application/javascript"
    Service-Worker-Allowed = "/"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "no-referrer"
    Permissions-Policy = "geolocation=(), microphone=(), camera=()"
```

## 📱 Génération de l'APK Android

### Pour Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Google Play)
flutter build appbundle --release

# Les fichiers seront dans:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### Héberger l'APK
1. Uploadez l'APK sur GitHub Releases
2. Ou utilisez un service comme Firebase App Distribution
3. Mettez à jour le lien dans `home_screen.dart`:
```dart
const url = 'https://github.com/votre-repo/quiz-flags/releases/latest/download/app-release.apk';
```

## 🌐 Autres Options de Déploiement

### Firebase Hosting
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser
firebase init hosting

# Déployer
firebase deploy --only hosting
```

### Vercel
```bash
# Installer Vercel CLI
npm install -g vercel

# Déployer
vercel --prod
```

### GitHub Pages
```bash
# Build
flutter build web --release --base-href "/nom-repo/"

# Déployer (via GitHub Actions ou manuellement)
# Copiez le contenu de build/web dans la branche gh-pages
```

## 🔧 Configuration Post-Déploiement

### 1. Tester la PWA
- Ouvrez votre site dans Chrome
- Ouvrez DevTools (F12)
- Allez dans l'onglet "Application"
- Vérifiez:
  - ✅ Manifest
  - ✅ Service Worker
  - ✅ Cache Storage

### 2. Tester l'installation
- Sur mobile: Menu > "Ajouter à l'écran d'accueil"
- Sur desktop: Icône d'installation dans la barre d'adresse

### 3. Tester le mode hors ligne
- Ouvrez l'application
- Activez le mode avion
- Vérifiez que l'app fonctionne toujours

## 📊 Optimisations

### Réduire la taille du build
```bash
flutter build web --release --web-renderer canvaskit --tree-shake-icons
```

### Activer la compression
Dans `netlify.toml`:
```toml
[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
    
[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

## 🔐 HTTPS et Domaine Personnalisé

### Sur Netlify
1. Allez dans "Domain settings"
2. Ajoutez votre domaine personnalisé
3. Netlify configure automatiquement HTTPS

### Certificat SSL
Netlify fournit automatiquement un certificat SSL gratuit via Let's Encrypt.

## 📱 Configuration des Icônes

Assurez-vous d'avoir les icônes dans `web/icons/`:
- Icon-192.png (192x192)
- Icon-512.png (512x512)
- Icon-maskable-192.png
- Icon-maskable-512.png

Générez-les avec:
```bash
flutter pub run flutter_launcher_icons:main
```

## 🎯 Checklist de Déploiement

- [ ] Build réussi sans erreurs
- [ ] Manifest.json configuré
- [ ] Service Worker fonctionnel
- [ ] Icônes PWA présentes
- [ ] HTTPS activé
- [ ] Test sur mobile
- [ ] Test sur desktop
- [ ] Test mode hors ligne
- [ ] APK généré et hébergé
- [ ] Lien de téléchargement mis à jour

## 🐛 Dépannage

### Le Service Worker ne s'installe pas
- Vérifiez que vous êtes en HTTPS
- Videz le cache du navigateur
- Vérifiez la console pour les erreurs

### L'application ne fonctionne pas hors ligne
- Vérifiez que le Service Worker est actif
- Vérifiez les ressources mises en cache
- Testez avec DevTools en mode "Offline"

### L'icône d'installation n'apparaît pas
- Vérifiez le manifest.json
- Assurez-vous que toutes les icônes existent
- Vérifiez que display: "standalone" est défini

## 📞 Support

Pour plus d'aide:
- Documentation Flutter Web: https://flutter.dev/web
- Documentation PWA: https://web.dev/progressive-web-apps/
- Documentation Netlify: https://docs.netlify.com/

## 🎉 Félicitations !

Votre application Quiz des Pays est maintenant déployée et accessible partout dans le monde ! 🌍
