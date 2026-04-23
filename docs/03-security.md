# 🔒 Sécurité & Authentification - CESIZen Mobile

## 🔐 Vue d'Ensemble Sécurité

L'application CESIZen implémente une sécurité multi-couches pour protéger les données utilisateurs et assurer l'intégrité des sessions.

### Principes de Sécurité
- **Défense en profondeur**: Multiples couches de protection
- **Zero Trust**: Vérification à chaque accès
- **Privacy by Design**: Protection dès la conception
- **Least Privilege**: Permissions minimales

## 🏦 Stockage des Tokens JWT

### Secure Storage Implementation
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  // Stockage sécurisé du token
  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Récupération sécurisée
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Suppression sécurisée
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

### Chiffrement Automatique
- **iOS**: Utilise Keychain avec chiffrement AES-256
- **Android**: Utilise Keystore avec chiffrement AES-GCM
- **Clés**: Générées automatiquement par le système

## 🔑 Firebase Authentication

### Configuration Firebase Auth
```dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login avec email/password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseError(e);
    }
  }

  // Login avec biométrie (via extension)
  Future<UserCredential> signInWithBiometric() async {
    // Vérifier support biométrie
    final canAuthenticate = await _canAuthenticateWithBiometric();
    if (!canAuthenticate) throw BiometricNotAvailableException();

    // Authentifier avec biométrie
    final authenticated = await _authenticateWithBiometric();
    if (!authenticated) throw BiometricAuthenticationFailedException();

    // Récupérer credentials stockés
    final email = await _getStoredEmail();
    final password = await _getStoredPassword();

    return await signInWithEmail(email, password);
  }
}
```

### Gestion des Sessions
```dart
class SessionManager {
  final SecureTokenStorage _tokenStorage;
  final FirebaseAuthService _authService;

  // Vérifier session valide
  Future<bool> isSessionValid() async {
    final token = await _tokenStorage.getToken();
    if (token == null) return false;

    // Vérifier expiration
    final payload = _decodeJwtPayload(token);
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    final now = DateTime.now();

    if (now.isAfter(expiry)) {
      // Tentative de refresh
      return await _refreshToken();
    }

    return true;
  }

  // Refresh automatique du token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      final newTokens = await _authService.refreshTokens(refreshToken);

      await _tokenStorage.storeToken(newTokens.accessToken);
      await _tokenStorage.storeRefreshToken(newTokens.refreshToken);

      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }
}
```

## 👆 Biométrie (Face ID / Touch ID)

### Configuration Biométrie
```dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Vérifier support
  Future<bool> canAuthenticate() async {
    final availableBiometrics = await _auth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty;
  }

  // Types de biométrie supportés
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  // Authentification biométrique
  Future<bool> authenticate({
    required String localizedReason,
    String? title,
    String? subtitle,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: title ?? 'Authentification requise',
            biometricHint: subtitle,
          ),
          IOSAuthMessages(
            lockOut: 'Trop de tentatives',
            goToSettingsButton: 'Paramètres',
            goToSettingsDescription: 'Configurez votre biométrie',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

### Intégration dans le Flow Auth
```dart
class AuthFlowManager {
  final BiometricService _biometricService;
  final SecureTokenStorage _tokenStorage;

  Future<void> attemptBiometricLogin() async {
    // Vérifier si biométrie activée
    final biometricEnabled = await _isBiometricEnabled();
    if (!biometricEnabled) return;

    // Vérifier support matériel
    final canAuth = await _biometricService.canAuthenticate();
    if (!canAuth) return;

    // Demander authentification
    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Confirmer votre identité pour accéder à CESIZen',
      title: 'Connexion CESIZen',
    );

    if (authenticated) {
      // Récupérer credentials stockés et connecter
      await _performStoredCredentialsLogin();
    }
  }

  Future<bool> _isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }
}
```

## 📋 Permissions & Autorisations

### Gestion des Permissions
```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  // Permission caméra (photos profil)
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Permission notifications
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Permission stockage (sauvegarde offline)
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Vérifier statut toutes permissions
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    return await [
      Permission.camera,
      Permission.notification,
      Permission.storage,
    ].request();
  }
}
```

### Matrice des Permissions

| Permission | Usage | Obligatoire | Plateforme |
|------------|-------|-------------|------------|
| **Camera** | Photos profil | Non | iOS/Android |
| **Storage** | Cache offline | Non | Android |
| **Notification** | Rappels exercices | Non | iOS/Android |
| **Biometric** | Auth rapide | Non | iOS/Android |

## 🔒 Chiffrement des Données

### Chiffrement des Données Sensibles
```dart
import 'package:encrypt/encrypt.dart';

class DataEncryption {
  static final _key = Key.fromSecureRandom(32);
  static final _iv = IV.fromSecureRandom(16);
  static final _encrypter = Encrypter(AES(_key));

  // Chiffrer données
  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // Déchiffrer données
  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
```

### Stockage des Clés de Chiffrement
- **iOS**: Keychain avec protection forte
- **Android**: Keystore avec invalidation sur root
- **Rotation**: Clés renouvelées automatiquement

## 🛡️ Protection contre les Attaques

### Rate Limiting
```dart
class RateLimiter {
  final Map<String, List<DateTime>> _attempts = {};
  static const _maxAttempts = 5;
  static const _windowMinutes = 15;

  bool isAllowed(String key) {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: _windowMinutes));

    _attempts[key] ??= [];
    _attempts[key]!.removeWhere((time) => time.isBefore(windowStart));

    if (_attempts[key]!.length >= _maxAttempts) {
      return false;
    }

    _attempts[key]!.add(now);
    return true;
  }
}
```

### Protection CSRF
- Tokens uniques par session
- Validation côté serveur
- Expiration automatique

### SSL Pinning
```dart
class SSLPinningClient extends HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final request = await super.getUrl(url);

    // Vérifier certificat serveur
    request.badCertificateCallback = (cert, host, port) {
      // Comparer avec certificat épinglé
      return _isValidCertificate(cert, host);
    };

    return request;
  }

  bool _isValidCertificate(X509Certificate cert, String host) {
    // Logique de validation certificat
    final pinnedCert = _getPinnedCertificate(host);
    return cert.pem == pinnedCert;
  }
}
```

## 📊 Audit & Monitoring

### Logging Sécurisé
```dart
class SecurityLogger {
  static const _logLevel = LogLevel.warning;

  void logSecurityEvent(String event, Map<String, dynamic> data) {
    if (_logLevel.index >= LogLevel.warning.index) {
      // Log vers service sécurisé (pas console)
      _sendToSecureLogService(event, data);
    }
  }

  void logAuthAttempt(String email, bool success) {
    logSecurityEvent('auth_attempt', {
      'email': _hashEmail(email), // Hash pour privacy
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
      'ip': _getClientIP(), // Si disponible
    });
  }
}
```

### Métriques Sécurité
- Taux de succès authentification
- Tentatives de connexion échouées
- Utilisation biométrie vs mot de passe
- Violations de permissions

## 🚨 Gestion des Incidents

### Procédures d'Urgence
1. **Détection**: Monitoring automatique
2. **Containment**: Déconnexion utilisateurs affectés
3. **Investigation**: Analyse logs sécurisés
4. **Recovery**: Restauration données saines
5. **Communication**: Notification utilisateurs

### Plan de Response
- **Temps de réponse**: < 1h pour incidents critiques
- **Communication**: Transparente avec utilisateurs
- **Compensation**: Crédits ou fonctionnalités bonus

---

*Dernière mise à jour: 21 avril 2026*
