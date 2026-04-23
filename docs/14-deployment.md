# 🚀 Déploiement - CESIZen Mobile

## 🎯 Vue d'Ensemble

Guide complet pour le déploiement de CESIZen Mobile sur iOS et Android, incluant build, release, monitoring et CI/CD.

### Plateformes Supportées
- ✅ **iOS**: App Store (iOS 12.0+)
- ✅ **Android**: Google Play Store (API 21+)
- ✅ **Web**: PWA (optionnel)

## 🛠️ Prérequis Déploiement

### Outils Requis
```bash
# Flutter
flutter --version  # 3.x.x minimum

# Android
Android Studio Arctic Fox | 2020.3.1+
Android SDK API 31+
Android SDK Build-Tools 31.0.0+

# iOS (macOS uniquement)
Xcode 13.0+
CocoaPods 1.11.0+
iOS Simulator 15.0+

# Fastlane (optionnel pour CI/CD)
fastlane --version  # 2.205.0+
```

### Configuration Environnement
```bash
# Variables d'environnement
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

# Vérifications
flutter doctor -v
```

## 📱 Build Android

### Configuration Build
**android/app/build.gradle**:
```gradle
android {
    compileSdkVersion 33
    defaultConfig {
        applicationId "com.cesizen.mobile"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        debug {
            debuggable true
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }

        release {
            debuggable false
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }
}

// Configuration signature release
android {
    signingConfigs {
        release {
            storeFile file('path/to/keystore.jks')
            storePassword 'store_password'
            keyAlias 'key_alias'
            keyPassword 'key_password'
        }
    }
}
```

### Génération Keystore
```bash
# Créer keystore
keytool -genkey -v -keystore cesizen.keystore -alias cesizen -keyalg RSA -keysize 2048 -validity 10000

# Informations requises:
# Mot de passe keystore
# Nom complet
# Unité organisationnelle
# Organisation
# Ville
# État/Province
# Code pays (2 lettres)
```

### Build APK Release
```bash
# Build APK
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (recommandé)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Optimisations Build
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700

# Configuration pour réduire taille
dependencies:
  flutter:
    sdk: flutter
  # Utiliser des packages légers
  # Éviter les assets inutiles
```

## 🍎 Build iOS

### Configuration Xcode
1. **Ouvrir projet**: `open ios/Runner.xcworkspace`
2. **Configuration générale**:
   - Bundle Identifier: `com.cesizen.mobile`
   - Version: `1.0.0`
   - Build: `1`
   - Deployment Target: `12.0`

3. **Capabilities**:
   - Background Modes: `Background fetch`, `Remote notifications`
   - Push Notifications: ✅
   - Sign in with Apple: ✅ (optionnel)

### Configuration Build iOS
**ios/Runner/Info.plist**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>CESIZen</string>
    <key>CFBundleIdentifier</key>
    <string>com.cesizen.mobile</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>

    <!-- Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Pour prendre des photos de profil</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Pour accéder à votre galerie photo</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Pour enregistrer des sessions audio</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Pour des fonctionnalités de localisation (optionnel)</string>

    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>

    <!-- Orientation -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
```

### Build iOS Release
```bash
# Nettoyer
flutter clean
cd ios
pod install
cd ..

# Build archive
flutter build ios --release --no-codesign

# Archive avec Xcode
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release archive -archivePath build/ios/Runner.xcarchive

# Export IPA
xcodebuild -exportArchive -archivePath build/ios/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath build/ios/Runner.ipa
```

### Configuration Export
**ios/exportOptions.plist**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>VOTRE_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## 🔥 Configuration Firebase

### Initialisation Firebase
```dart
// lib/core/config/firebase_config.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configuration Crashlytics
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Configuration Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
  }
}
```

### Génération Options Firebase
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialiser FlutterFire
flutterfire configure

# Sélectionner projet Firebase
# Génère lib/firebase_options.dart automatiquement
```

### Configuration Crashlytics
```dart
// Rapport d'erreur
void reportError(dynamic error, StackTrace stackTrace) {
  FirebaseCrashlytics.instance.recordError(error, stackTrace);
}

// Informations utilisateur
void setUserInfo(String userId, String email) {
  FirebaseCrashlytics.instance.setUserIdentifier(userId);
  FirebaseCrashlytics.instance.setCustomKey('email', email);
}
```

## 🚀 Publication App Store

### Préparation App Store Connect

1. **Créer app**:
   - Aller sur [App Store Connect](https://appstoreconnect.apple.com)
   - Apps → New App
   - Bundle ID: `com.cesizen.mobile`

2. **Métadonnées**:
   - Nom: CESIZen
   - Sous-titre: Respirer. Prévenir. Vivre.
   - Description: Application de respiration et prévention santé
   - Mots-clés: respiration, santé, bien-être, prévention

3. **Captures d'écran** (6.5", 5.5", 12.9"):
   - Taille: 1242x2688, 1242x2208, 2048x2732
   - Format PNG/JPG

4. **Icônes**:
   - App Icon: 1024x1024
   - Alternate App Icons (optionnel)

### Upload avec Transporter
```bash
# Installer Transporter
# Télécharger depuis https://apps.apple.com/us/app/transporter/id1450874784

# Upload IPA
# Ouvrir Transporter → Add App → Sélectionner Runner.ipa
```

### Upload avec Xcode
```bash
# Archive et upload
xcodebuild -exportArchive -archivePath build/ios/Runner.xcarchive -exportOptionsPlist ios/exportOptions.plist -exportPath build/ios/

# Puis ouvrir Xcode → Window → Organizer → Upload to App Store
```

## 📱 Publication Google Play

### Préparation Google Play Console

1. **Créer app**:
   - Aller sur [Google Play Console](https://play.google.com/console)
   - Créer app → App gratuite/payant
   - Nom: CESIZen

2. **Store Listing**:
   - Titre: CESIZen
   - Description courte: Application de respiration guidée
   - Description complète: Détails fonctionnalités
   - Captures d'écran: 8 images (phone: 1080x1920, tablet: 1200x1920)

3. **Graphismes**:
   - Icône: 512x512
   - Feature Graphic: 1024x500
   - TV Banner: 1280x720 (optionnel)

### Upload App Bundle
```bash
# Upload avec bundletool (recommandé)
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=cesizen.apks --ks=cesizen.keystore --ks-pass=pass:store_password --ks-key-alias=cesizen --key-pass=pass:key_password

# Ou directement via Play Console
# Release → Production → Create Release → Upload bundle
```

### Configuration Tracks
- **Internal Testing**: Tests internes
- **Closed Testing**: Beta testers
- **Open Testing**: Public beta
- **Production**: Release publique

## 🔄 CI/CD avec GitHub Actions

### Configuration Workflow
**.github/workflows/deploy.yml**:
```yaml
name: Deploy CESIZen

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      - run: flutter pub get
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: android-bundle
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.7.0'
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app

  deploy-android:
    needs: build-android
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: android-bundle
      - run: echo "Upload to Google Play Store"
      # Utiliser fastlane ou API Google Play

  deploy-ios:
    needs: build-ios
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/download-artifact@v3
        with:
          name: ios-build
      - run: echo "Upload to App Store Connect"
      # Utiliser fastlane ou API App Store
```

### Configuration Fastlane
**fastlane/Fastfile**:
```ruby
platform :android do
  desc "Deploy to Google Play"
  lane :deploy do
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
    )
  end
end

platform :ios do
  desc "Deploy to App Store"
  lane :deploy do
    api_key = app_store_connect_api_key(
      key_id: ENV['APP_STORE_KEY_ID'],
      issuer_id: ENV['APP_STORE_ISSUER_ID'],
      key_content: ENV['APP_STORE_PRIVATE_KEY'],
    )

    upload_to_app_store(
      api_key: api_key,
      skip_metadata: true,
      skip_screenshots: true,
      precheck_include_in_app_purchases: false,
    )
  end
end
```

## 📊 Monitoring & Analytics

### Firebase Analytics
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Événements personnalisés
  Future<void> logExerciseStarted(String exerciseId, String category) async {
    await _analytics.logEvent(
      name: 'exercise_started',
      parameters: {
        'exercise_id': exerciseId,
        'category': category,
      },
    );
  }

  Future<void> logArticleRead(String articleId, String category) async {
    await _analytics.logEvent(
      name: 'article_read',
      parameters: {
        'article_id': articleId,
        'category': category,
      },
    );
  }

  Future<void> logSessionCompleted({
    required String exerciseId,
    required Duration duration,
    required SessionQuality quality,
  }) async {
    await _analytics.logEvent(
      name: 'session_completed',
      parameters: {
        'exercise_id': exerciseId,
        'duration_seconds': duration.inSeconds,
        'quality': quality.name,
      },
    );
  }

  // Propriétés utilisateur
  Future<void> setUserProperties(String userId, bool isPremium) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'premium', value: isPremium.toString());
  }
}
```

### Crashlytics Monitoring
```dart
class CrashReportingService {
  // Rapport d'erreur avec contexte
  static void reportError(
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: context?['reason'],
      information: context?.entries.map((e) => '${e.key}: ${e.value}').toList(),
    );
  }

  // Contexte utilisateur
  static void setUserContext(String userId, String email) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
    FirebaseCrashlytics.instance.setCustomKey('user_email', email);
  }

  // Logs personnalisés
  static void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }
}
```

### Métriques Performance
```dart
class PerformanceMonitoring {
  static void monitorApiCall(String endpoint, Duration duration, bool success) {
    FirebasePerformance.instance.newHttpMetric(endpoint, HttpMethod.Get)
      ..start()
      ..stop();

    // Métriques personnalisées
    FirebaseAnalytics.instance.logEvent(
      name: 'api_performance',
      parameters: {
        'endpoint': endpoint,
        'duration_ms': duration.inMilliseconds,
        'success': success,
      },
    );
  }

  static void monitorScreenLoad(String screenName, Duration loadTime) {
    FirebaseAnalytics.instance.logEvent(
      name: 'screen_load',
      parameters: {
        'screen_name': screenName,
        'load_time_ms': loadTime.inMilliseconds,
      },
    );
  }
}
```

## 🐛 Debugging & Troubleshooting

### Logs Build
```bash
# Logs détaillés Flutter
flutter build apk --verbose

# Logs Xcode
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release clean build -verbose

# Logs Gradle
cd android && ./gradlew assembleRelease --info
```

### Problèmes Courants

#### Android
```gradle
// Problème: MultiDex
defaultConfig {
    multiDexEnabled true
}

// Problème: R8/ProGuard
buildTypes {
    release {
        minifyEnabled false  // Temporaire pour debug
    }
}
```

#### iOS
```bash
# Problème: CocoaPods
cd ios
pod deintegrate
pod install

# Problème: Provisioning Profile
# Vérifier dans Xcode → Signing & Capabilities
```

### Tests de Validation
```bash
# Test Android
flutter build apk --release --split-per-abi
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Test iOS
flutter build ios --release
xcrun simctl install booted build/ios/iphoneos/Runner.app
```

## 📋 Checklist Déploiement

### Pré-déploiement
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Build release réussi
- [ ] Analytics configuré
- [ ] Crash reporting configuré
- [ ] Permissions configurées
- [ ] Assets optimisés

### App Store
- [ ] Bundle ID correct
- [ ] Version et build number
- [ ] Captures d'écran
- [ ] Description et métadonnées
- [ ] Privacy Policy
- [ ] TestFlight beta (optionnel)

### Google Play
- [ ] Package name correct
- [ ] Version code/name
- [ ] Store listing complet
- [ ] Content rating
- [ ] Privacy Policy
- [ ] Internal testing track

### Post-déploiement
- [ ] Monitoring erreurs
- [ ] Analytics tracking
- [ ] Feedback utilisateurs
- [ ] Mises à jour correctives

---

*Dernière mise à jour: 21 avril 2026*
