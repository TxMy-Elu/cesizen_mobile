# 🔐 Authentification - CESIZen Mobile

## 📱 Vue d'Ensemble Authentification

Le système d'authentification de CESIZen gère l'accès utilisateur avec support multi-méthodes et gestion d'état robuste.

### Fonctionnalités Clés
- ✅ Login/Register avec validation temps réel
- ✅ Authentification biométrique
- ✅ Gestion automatique des tokens
- ✅ États d'authentification persistants
- ✅ Déconnexion sécurisée

## 🎨 Écrans Authentification

### 1️⃣ Écran Login

#### Wireframe Description
```
┌─────────────────────────────────┐
│          CESIZen                │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 📧 Email                │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔒 Mot de passe         │    │
│  └─────────────────────────┘    │
│                                 │
│  [ 🔓 Se connecter ]            │
│                                 │
│  [ 👆 Connexion biométrique ]   │
│                                 │
│  Pas de compte ? S'inscrire     │
└─────────────────────────────────┘
```

#### Implémentation Flutter
```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = context.read<BiometricService>();
    _biometricAvailable = await biometricService.canAuthenticate();
    setState(() {});
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navigation vers dashboard
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final authService = context.read<AuthService>();
      await authService.signInWithBiometric();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentification biométrique échouée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo et titre
                const Text(
                  'CESIZen',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),

                // Champ email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email requis';
                    if (!value!.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Mot de passe requis';
                    if (value!.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Bouton connexion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Se connecter'),
                  ),
                ),

                // Bouton biométrique
                if (_biometricAvailable) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _biometricLogin,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Connexion biométrique'),
                    ),
                  ),
                ],

                // Lien vers inscription
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Pas de compte ? S'inscrire"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2️⃣ Écran Register

#### Wireframe Description
```
┌─────────────────────────────────┐
│        S'inscrire               │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 👤 Nom complet          │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 📧 Email                │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔒 Mot de passe         │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔒 Confirmer mot de passe│    │
│  └─────────────────────────┘    │
│                                 │
│  [ 📝 S'inscrire ]              │
│                                 │
│  Déjà un compte ? Se connecter  │
└─────────────────────────────────┘
```

#### Implémentation
```dart
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navigation vers vérification email ou login
      Navigator.of(context).pushReplacementNamed('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie ! Connectez-vous.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inscription: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S'inscrire")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Champ nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Nom requis';
                    if (value!.length < 2) return 'Nom trop court';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email requis';
                    if (!value!.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Mot de passe requis';
                    if (value!.length < 6) return 'Minimum 6 caractères';
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Au moins une majuscule';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Au moins un chiffre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer mot de passe',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Mots de passe différents';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Bouton inscription
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text("S'inscrire"),
                  ),
                ),

                // Lien vers connexion
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Déjà un compte ? Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 🔄 Flow Authentification

### Diagramme de Flux
```
App Start
    ↓
Vérifier Token Stocké
    ↓
Token Valide? ──Oui──→ Dashboard
    ↓ Non
Afficher Login Screen
    ↓
Utilisateur saisit credentials
    ↓
Validation côté client
    ↓
Appel API Authentification
    ↓
Succès ──Oui──→ Stocker Token → Dashboard
    ↓ Non
Afficher Erreur → Retry
```

### Gestion d'État Auth
```dart
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

  final AuthService _authService;
  final SecureTokenStorage _tokenStorage;

  AuthProvider(this._authService, this._tokenStorage) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _state = _state.copyWith(status: AuthStatus.loading);
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        // Vérifier validité token
        final isValid = await _authService.validateToken(token);
        if (isValid) {
          final user = await _authService.getCurrentUser();
          _state = _state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          await _tokenStorage.clearTokens();
          _state = _state.copyWith(status: AuthStatus.unauthenticated);
        }
      } else {
        _state = _state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      _state = _state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _state = _state.copyWith(status: AuthStatus.loading);
    notifyListeners();

    try {
      final result = await _authService.signInWithEmail(email, password);
      final user = result.user;

      _state = _state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _tokenStorage.clearTokens();

    _state = _state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );

    notifyListeners();
  }
}
```

## 🔄 Refresh Token Automatique

### Service Refresh Token
```dart
class TokenRefreshService {
  final AuthService _authService;
  final SecureTokenStorage _tokenStorage;
  Timer? _refreshTimer;

  void startTokenRefreshTimer() {
    // Programmer refresh 5min avant expiration
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshTokenIfNeeded();
    });
  }

  Future<void> _refreshTokenIfNeeded() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) return;

      final payload = _decodeJwtPayload(token);
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final now = DateTime.now();
      final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

      if (fiveMinutesFromNow.isAfter(expiry)) {
        await _refreshToken();
      }
    } catch (e) {
      // Gérer erreur refresh
      print('Erreur refresh token: $e');
    }
  }

  Future<void> _refreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return;

    final newTokens = await _authService.refreshTokens(refreshToken);

    await _tokenStorage.storeToken(newTokens.accessToken);
    await _tokenStorage.storeRefreshToken(newTokens.refreshToken);
  }

  void stopTokenRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return json.decode(resp);
  }
}
```

## 🚪 Déconnexion Sécurisée

### Processus Déconnexion
```dart
class LogoutManager {
  final AuthProvider _authProvider;
  final TokenRefreshService _tokenRefreshService;
  final SecureTokenStorage _tokenStorage;
  final LocalDatabase _localDb;

  Future<void> logout() async {
    try {
      // Arrêter refresh timer
      _tokenRefreshService.stopTokenRefreshTimer();

      // Déconnexion Firebase
      await FirebaseAuth.instance.signOut();

      // Supprimer tokens locaux
      await _tokenStorage.clearTokens();

      // Nettoyer données locales sensibles
      await _localDb.clearSensitiveData();

      // Mettre à jour état auth
      await _authProvider.signOut();

      // Navigation vers login
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

    } catch (e) {
      // Forcer déconnexion même en cas d'erreur
      await _authProvider.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
```

## 🧪 Tests Authentification

### Tests Unitaires
```dart
void main() {
  group('AuthProvider', () {
    test('should initialize with unauthenticated state', () {
      final provider = AuthProvider(mockAuthService, mockTokenStorage);
      expect(provider.state.status, AuthStatus.initial);
    });

    test('should handle successful sign in', () async {
      final provider = AuthProvider(mockAuthService, mockTokenStorage);

      await provider.signIn('test@example.com', 'password');

      expect(provider.state.status, AuthStatus.authenticated);
      expect(provider.state.user, isNotNull);
    });

    test('should handle sign in error', () async {
      final provider = AuthProvider(mockAuthService, mockTokenStorage);

      await provider.signIn('invalid@email.com', 'wrong');

      expect(provider.state.status, AuthStatus.unauthenticated);
      expect(provider.state.errorMessage, isNotNull);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
