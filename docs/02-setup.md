# 🔧 Installation & Configuration - CESIZen Mobile

## 📋 Prérequis Système

### Pour Windows
- **OS**: Windows 10/11 (64-bit)
- **RAM**: Minimum 8GB, recommandé 16GB
- **Espace disque**: 10GB libre
- **CPU**: Intel i5 ou équivalent

### Pour macOS
- **OS**: macOS 10.15+ (Catalina ou supérieur)
- **RAM**: Minimum 8GB
- **Espace disque**: 15GB libre

### Pour Linux
- **OS**: Ubuntu 18.04+ ou équivalent
- **RAM**: Minimum 8GB
- **Espace disque**: 10GB libre

## 🛠️ Installation Flutter SDK

### Étape 1: Télécharger Flutter
```powershell
# Windows PowerShell
# Télécharger depuis https://flutter.dev/docs/get-started/install/windows
# Ou utiliser Chocolatey
choco install flutter
```

### Étape 2: Ajouter au PATH
```powershell
# Vérifier l'installation
flutter --version
# Output attendu: Flutter 3.x.x • channel stable
```

### Étape 3: Accepter les licences
```powershell
flutter doctor --android-licenses
flutter doctor --ios-licenses  # macOS uniquement
```

### Étape 4: Vérifier l'installation
```powershell
flutter doctor
```

## 📱 Configuration Android

### JDK 11+
```powershell
# Installer OpenJDK
choco install openjdk11
# Ou télécharger depuis https://adoptium.net/
```

### Android Studio
1. Télécharger depuis https://developer.android.com/studio
2. Installer SDK Android
3. Créer un AVD (émulateur)

### Variables d'environnement
```powershell
# Ajouter à votre PATH
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\tools;$env:ANDROID_HOME\platform-tools"
```

## 🍎 Configuration iOS (macOS uniquement)

### Xcode
1. Installer depuis App Store
2. Accepter la licence: `sudo xcodebuild -license accept`
3. Installer outils ligne de commande: `xcode-select --install`

### CocoaPods
```bash
sudo gem install cocoapods
pod setup
```

## 📦 Installation des Dépendances

### Cloner le projet
```powershell
git clone https://github.com/elio/cesizen_mobile.git
cd cesizen_mobile
```

### Installer packages Flutter
```powershell
flutter pub get
```

### Vérifier pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  get: ^4.6.5
  firebase_core: ^2.7.0
  firebase_auth: ^4.2.0
  cloud_firestore: ^4.4.0
  firebase_storage: ^11.0.0
  sqflite: ^2.2.0
  http: ^1.0.0
  shared_preferences: ^2.1.0
  flutter_secure_storage: ^8.0.0
  image_picker: ^1.0.0
  permission_handler: ^10.2.0
  connectivity_plus: ^3.0.0
  intl: ^0.18.0
```

## 🔑 Configuration Firebase

### Étape 1: Créer projet Firebase
1. Aller sur https://console.firebase.google.com/
2. Créer nouveau projet "CESIZen Mobile"
3. Activer Authentication, Firestore, Storage

### Étape 2: Télécharger fichiers config
- **Android**: `google-services.json` → `android/app/`
- **iOS**: `GoogleService-Info.plist` → `ios/Runner/`

### Étape 3: Configurer règles Firestore
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /articles/{articleId} {
      allow read: if request.auth != null;
      allow write: if false; // Read-only pour articles
    }
  }
}
```

## 🚀 Lancement Local

### Émulateur Android
```powershell
# Lister émulateurs
flutter emulators

# Lancer émulateur
flutter emulators --launch Pixel_4_API_30

# Lancer app
flutter run
```

### Simulateur iOS (macOS)
```bash
# Lister simulateurs
flutter devices

# Lancer simulateur
open -a Simulator

# Lancer app
flutter run
```

### Device physique
```powershell
# Brancher device en USB
flutter devices

# Lancer sur device
flutter run -d <device_id>
```

## 🔧 Configuration Environnement

### Créer fichier .env
```bash
# Dans la racine du projet
touch .env
```

Contenu du .env:
```env
API_BASE_URL=https://api.cesizen.com/v1
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=cesizen-mobile
FIREBASE_APP_ID=your_app_id
DEBUG_MODE=true
```

### Configuration build
**android/app/build.gradle**:
```gradle
android {
    defaultConfig {
        applicationId "com.cesizen.mobile"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

**ios/Runner/Info.plist**:
```xml
<key>CFBundleDisplayName</key>
<string>CESIZen</string>
<key>CFBundleIdentifier</key>
<string>com.cesizen.mobile</string>
```

## 🐛 Troubleshooting

### Erreur: "flutter doctor" ne trouve pas Android SDK
```powershell
# Définir ANDROID_HOME
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
```

### Erreur: CocoaPods non installé
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Erreur: Build iOS échoue
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Erreur: Émulateur ne démarre pas
```powershell
# Android Studio → AVD Manager → Create Virtual Device
# Sélectionner API 30+ et armeabi-v7a
```

### Erreur: Permission denied sur macOS
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Erreur: Gradle build failed
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## 📊 Vérifications Post-Installation

### Tests de base
```powershell
# Vérifier Flutter
flutter doctor -v

# Vérifier packages
flutter pub outdated

# Build debug
flutter build apk --debug

# Build iOS (macOS)
flutter build ios --debug
```

### Tests fonctionnels
```powershell
# Lancer tests unitaires
flutter test

# Lancer tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 🚀 Commandes Utiles

```powershell
# Mise à jour Flutter
flutter upgrade

# Mise à jour packages
flutter pub upgrade

# Nettoyer cache
flutter clean && flutter pub get

# Analyser code
flutter analyze

# Formater code
flutter format lib/

# Générer code (si utilisé)
flutter pub run build_runner build
```

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez `flutter doctor`
2. Consultez les logs: `flutter logs`
3. Ouvrez une issue sur GitHub
4. Contactez l'équipe dev

---

*Dernière mise à jour: 21 avril 2026*
