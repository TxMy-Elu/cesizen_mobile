# 🔐 Interface Authentification - CESIZen Mobile

## 🎯 Vue d'Ensemble

Les écrans d'authentification offrent une expérience utilisateur fluide avec validation temps réel et gestion d'erreurs intuitive.

### Fonctionnalités Clés
- ✅ Validation temps réel des champs
- ✅ Messages d'erreur contextuels
- ✅ États de chargement visuels
- ✅ Support biométrie intégré
- ✅ Transitions fluides

## 🎨 Design System

### Palette Couleurs
```dart
class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const secondary = Color(0xFF81C784);
  static const error = Color(0xFFE57373);
  static const success = Color(0xFF81C784);
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}
```

### Typographie
```dart
class AppTextStyles {
  static const headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const error = TextStyle(
    fontSize: 12,
    color: AppColors.error,
  );
}
```

### Composants Réutilisables

#### Champ de Saisie Personnalisé
```dart
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
  }

  void _showError() {
    setState(() => _hasError = true);
    _animationController.forward(from: 0);
  }

  void _clearError() {
    setState(() => _hasError = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasError ? AppColors.error : AppColors.textSecondary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.enabled ? Colors.white : Colors.grey[100],
            ),
            validator: (value) {
              final error = widget.validator?.call(value);
              if (error != null) {
                _showError();
              } else {
                _clearError();
              }
              return error;
            },
            onChanged: widget.onChanged,
          ),
        );
      },
    );
  }
}
```

#### Bouton d'Action Auth
```dart
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;

  const AuthButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary ? const BorderSide(color: AppColors.primary) : BorderSide.none,
          ),
          elevation: isSecondary ? 0 : 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: AppTextStyles.button),
      ),
    );
  }
}
```

## 📱 Écran Login

### Wireframe Complet
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
│  Mot de passe oublié ?          │
│                                 │
│  ──────────────────────────     │
│                                 │
│  Pas de compte ? S'inscrire     │
└─────────────────────────────────┘
```

### Implémentation Complète
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  bool _isLoading = false;
  bool _biometricAvailable = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Animation logo
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeIn,
    ));

    _logoAnimationController.forward();

    // Vérifier biométrie
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final biometricService = context.read<BiometricService>();
      _biometricAvailable = await biometricService.canAuthenticate();
      setState(() {});
    } catch (e) {
      // Ignorer erreur biométrie
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navigation réussie
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithBiometric();
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentification biométrique échouée';
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Aucun compte trouvé avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'user-disabled':
          return 'Ce compte a été désactivé';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessayez plus tard';
        default:
          return 'Erreur de connexion';
      }
    }
    return error.toString();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo animé
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.spa,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Titre
                Text(
                  'Bienvenue',
                  style: AppTextStyles.headline1,
                ),

                const SizedBox(height: 8),

                Text(
                  'Connectez-vous à votre compte',
                  style: AppTextStyles.body2,
                ),

                const SizedBox(height: 48),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Champ email
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez saisir votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Veuillez saisir un email valide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ mot de passe
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez saisir votre mot de passe';
                    }
                    if (value!.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Lien mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton connexion
                AuthButton(
                  text: 'Se connecter',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                // Bouton biométrique
                if (_biometricAvailable) ...[
                  AuthButton(
                    text: 'Connexion biométrique',
                    onPressed: _biometricLogin,
                    isSecondary: true,
                  ),
                  const SizedBox(height: 16),
                ],

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: AppTextStyles.body2,
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 16),

                // Lien inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas de compte ? ',
                      style: AppTextStyles.body2,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'S\'inscrire',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## 📝 Écran Register

### Wireframe Complet
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
│  [Force mot de passe: ████░░]   │
│                                 │
│  [ 📝 S'inscrire ]              │
│                                 │
│  ──────────────────────────     │
│                                 │
│  Déjà un compte ? Se connecter  │
└─────────────────────────────────┘
```

### Implémentation Complète
```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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
  String? _errorMessage;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
    });
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Faible';
      case PasswordStrength.medium:
        return 'Moyen';
      case PasswordStrength.strong:
        return 'Fort';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navigation vers vérification email
      Navigator.of(context).pushReplacementNamed('/email-verification');
    } catch (e) {
      setState(() {
        _errorMessage = _getRegisterErrorMessage(e);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getRegisterErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'weak-password':
          return 'Le mot de passe est trop faible';
        case 'invalid-email':
          return 'Email invalide';
        default:
          return 'Erreur lors de l\'inscription';
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Titre
                Text(
                  'Créer un compte',
                  style: AppTextStyles.headline1,
                ),

                const SizedBox(height: 8),

                Text(
                  'Rejoignez CESIZen pour commencer votre voyage',
                  style: AppTextStyles.body2,
                ),

                const SizedBox(height: 32),

                // Message d'erreur
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Champ nom
                AuthTextField(
                  controller: _nameController,
                  label: 'Nom complet',
                  icon: Icons.person_outlined,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez saisir votre nom';
                    }
                    if (value!.length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ email
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez saisir votre email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Veuillez saisir un email valide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Champ mot de passe
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  onChanged: _updatePasswordStrength,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez saisir un mot de passe';
                    }
                    if (value!.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    if (_passwordStrength == PasswordStrength.weak) {
                      return 'Le mot de passe est trop faible';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Indicateur force mot de passe
                if (_passwordController.text.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Force: ',
                        style: AppTextStyles.body2,
                      ),
                      Text(
                        _getStrengthText(_passwordStrength),
                        style: TextStyle(
                          color: _getStrengthColor(_passwordStrength),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength == PasswordStrength.weak ? 0.3 :
                                 _passwordStrength == PasswordStrength.medium ? 0.6 : 1.0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStrengthColor(_passwordStrength),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Champ confirmation mot de passe
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Bouton inscription
                AuthButton(
                  text: 'S\'inscrire',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: AppTextStyles.body2,
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 16),

                // Lien connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: AppTextStyles.body2,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'Se connecter',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PasswordStrength { weak, medium, strong }
```

## 🔄 États et Transitions

### Gestion d'État UI
```dart
enum AuthUIState { idle, loading, success, error }

class AuthUIStateNotifier extends ChangeNotifier {
  AuthUIState _state = AuthUIState.idle;
  String? _errorMessage;
  String? _successMessage;

  AuthUIState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setLoading() {
    _state = AuthUIState.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setSuccess([String? message]) {
    _state = AuthUIState.success;
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void setError(String message) {
    _state = AuthUIState.error;
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _state = AuthUIState.idle;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
```

### Animations de Transition
```dart
class AuthTransition extends PageRouteBuilder {
  final Widget page;

  AuthTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
```

## 📱 Responsive & Accessibilité

### Adaptations Responsive
- **Mobile**: Layout standard
- **Tablet**: Champs plus larges, espacement ajusté
- **Paysage**: Layout adapté

### Accessibilité
- **TalkBack/VoiceOver**: Labels descriptifs
- **Taille texte**: Respect paramètres système
- **Contraste**: Couleurs haute visibilité
- **Navigation**: Support clavier complet

## 🧪 Tests UI Authentification

### Tests de Validation
```dart
void main() {
  group('AuthTextField', () {
    testWidgets('shows error for empty email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: TextEditingController(),
              label: 'Email',
              icon: Icons.email,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '');
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('LoginScreen', () {
    testWidgets('shows loading state during login', (tester) async {
      // Test implementation
    });

    testWidgets('navigates to home on successful login', (tester) async {
      // Test implementation
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
