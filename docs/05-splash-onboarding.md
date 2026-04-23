# 🚀 Splash Screen & Onboarding - CESIZen Mobile

## 🎯 Vue d'Ensemble

L'écran de splash et le processus d'onboarding introduisent l'utilisateur à CESIZen avec une expérience fluide et engageante.

### Objectifs
- ✅ Branding et première impression positive
- ✅ Introduction des fonctionnalités clés
- ✅ Collecte de préférences utilisateur
- ✅ Navigation vers authentification ou app

## 🎨 Splash Screen

### Wireframe Description
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│            CESIZen              │
│                                 │
│         [Logo animé]            │
│                                 │
│     Respirer. Prévenir. Vivre.  │
│                                 │
│                                 │
│         [Loader animé]          │
│                                 │
└─────────────────────────────────┘
```

### Implémentation Flutter
```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Démarrer animation
    _animationController.forward();

    // Navigation après délai
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));

    // Vérifier si première utilisation
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      // Première fois → Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // Vérifier authentification
      final authProvider = context.read<AuthProvider>();
      if (authProvider.state.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animé
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.spa, // Icône respiration
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Nom app
                const Text(
                  'CESIZen',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                const Text(
                  'Respirer. Prévenir. Vivre.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),

                // Loader animé
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

## 📖 Onboarding Process

### Structure Onboarding

L'onboarding comprend 4 écrans principaux :

1. **Bienvenue** - Introduction à CESIZen
2. **Respiration** - Fonctionnalité principale
3. **Prévention** - Articles et conseils
4. **Personnalisation** - Préférences utilisateur

### 1️⃣ Écran Bienvenue

#### Wireframe
```
┌─────────────────────────────────┐
│                                 │
│         Bienvenue sur           │
│           CESIZen !             │
│                                 │
│    [Illustration bienvenue]     │
│                                 │
│ Votre compagnon pour une vie    │
│ plus saine et équilibrée.       │
│                                 │
│         [Suivant]               │
└─────────────────────────────────┘
```

#### Implémentation
```dart
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: 'Bienvenue sur\nCESIZen !',
      subtitle: 'Votre compagnon pour une vie plus saine et équilibrée.',
      illustration: Image.asset('assets/images/welcome_illustration.png'),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingBreathingScreen()),
      ),
    );
  }
}
```

### 2️⃣ Écran Respiration

#### Wireframe
```
┌─────────────────────────────────┐
│                                 │
│     Exercices de Respiration    │
│                                 │
│   [Animation respiration]       │
│                                 │
│ Découvrez des exercices guidés  │
│ pour réduire le stress et       │
│ améliorer votre bien-être.      │
│                                 │
│         [Suivant]               │
└─────────────────────────────────┘
```

#### Implémentation
```dart
class OnboardingBreathingScreen extends StatelessWidget {
  const OnboardingBreathingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: 'Exercices de\nRespiration',
      subtitle: 'Découvrez des exercices guidés pour réduire le stress et améliorer votre bien-être.',
      illustration: const BreathingAnimationWidget(),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPreventionScreen()),
      ),
    );
  }
}
```

### 3️⃣ Écran Prévention

#### Wireframe
```
┌─────────────────────────────────┐
│                                 │
│   Articles de Prévention        │
│                                 │
│   [Illustration articles]       │
│                                 │
│ Accédez à des articles experts  │
│ sur la santé mentale et         │
│ physique.                       │
│                                 │
│         [Suivant]               │
└─────────────────────────────────┘
```

#### Implémentation
```dart
class OnboardingPreventionScreen extends StatelessWidget {
  const OnboardingPreventionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: 'Articles de\nPrévention',
      subtitle: 'Accédez à des articles experts sur la santé mentale et physique.',
      illustration: Image.asset('assets/images/articles_illustration.png'),
      onNext: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPreferencesScreen()),
      ),
    );
  }
}
```

### 4️⃣ Écran Personnalisation

#### Wireframe
```
┌─────────────────────────────────┐
│                                 │
│   Personnalisez votre           │
│        expérience               │
│                                 │
│  [ ] Notifications quotidiennes │
│  [ ] Rappels d'exercices        │
│  [ ] Articles recommandés       │
│                                 │
│   Thème: ☀️ Clair 🌙 Sombre     │
│                                 │
│       [Commencer]               │
└─────────────────────────────────┘
```

#### Implémentation
```dart
class OnboardingPreferencesScreen extends StatefulWidget {
  const OnboardingPreferencesScreen({Key? key}) : super(key: key);

  @override
  _OnboardingPreferencesScreenState createState() =>
      _OnboardingPreferencesScreenState();
}

class _OnboardingPreferencesScreenState
    extends State<OnboardingPreferencesScreen> {
  bool _dailyNotifications = true;
  bool _exerciseReminders = true;
  bool _recommendedArticles = true;
  bool _darkTheme = false;

  Future<void> _completeOnboarding() async {
    // Sauvegarder préférences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    await prefs.setBool('daily_notifications', _dailyNotifications);
    await prefs.setBool('exercise_reminders', _exerciseReminders);
    await prefs.setBool('recommended_articles', _recommendedArticles);
    await prefs.setBool('dark_theme', _darkTheme);

    // Navigation vers login
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Personnalisez votre\nexpérience',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Préférences notifications
              SwitchListTile(
                title: const Text('Notifications quotidiennes'),
                subtitle: const Text('Rappels pour vos exercices'),
                value: _dailyNotifications,
                onChanged: (value) => setState(() => _dailyNotifications = value),
              ),

              SwitchListTile(
                title: const Text('Rappels d\'exercices'),
                subtitle: const Text('Notifications programmées'),
                value: _exerciseReminders,
                onChanged: (value) => setState(() => _exerciseReminders = value),
              ),

              SwitchListTile(
                title: const Text('Articles recommandés'),
                subtitle: const Text('Suggestions personnalisées'),
                value: _recommendedArticles,
                onChanged: (value) => setState(() => _recommendedArticles = value),
              ),

              const SizedBox(height: 24),

              // Sélection thème
              const Text(
                'Thème préféré',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('☀️ Clair'),
                    selected: !_darkTheme,
                    onSelected: (selected) {
                      if (selected) setState(() => _darkTheme = false);
                    },
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('🌙 Sombre'),
                    selected: _darkTheme,
                    onSelected: (selected) {
                      if (selected) setState(() => _darkTheme = true);
                    },
                  ),
                ],
              ),

              const Spacer(),

              // Bouton commencer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Commencer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🧩 Composants Réutilisables

### Widget Page Onboarding
```dart
class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget illustration;
  final VoidCallback onNext;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Illustration
              Expanded(
                child: Center(child: illustration),
              ),

              const SizedBox(height: 48),

              // Titre
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Sous-titre
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Indicateur progression
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 // Adapter selon écran actuel
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Bouton suivant
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Suivant'),
                ),
              ),

              const SizedBox(height: 24),

              // Bouton passer
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Passer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Animation Respiration
```dart
class BreathingAnimationWidget extends StatefulWidget {
  const BreathingAnimationWidget({Key? key}) : super(key: key);

  @override
  _BreathingAnimationWidgetState createState() =>
      _BreathingAnimationWidgetState();
}

class _BreathingAnimationWidgetState extends State<BreathingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: const Icon(
              Icons.air,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
```

## 🔄 Gestion d'État Onboarding

### Provider Onboarding
```dart
class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  final Map<String, dynamic> _preferences = {};

  int get currentPage => _currentPage;
  Map<String, dynamic> get preferences => _preferences;

  void nextPage() {
    if (_currentPage < 3) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void setPreference(String key, dynamic value) {
    _preferences[key] = value;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // Sauvegarder préférences
    _preferences.forEach((key, value) {
      if (value is bool) {
        prefs.setBool(key, value);
      } else if (value is String) {
        prefs.setString(key, value);
      }
    });

    // Marquer onboarding terminé
    await prefs.setBool('onboarding_completed', true);
  }
}
```

## 📱 Responsive Design

### Adaptations Mobile
- **Portrait**: Layout vertical standard
- **Landscape**: Ajustement espacement et tailles
- **Petits écrans**: Réduction padding et tailles texte
- **Grands écrans**: Optimisation tablette

### Accessibilité
- **Taille texte**: Respecter paramètres système
- **Contraste**: Couleurs haute visibilité
- **Navigation**: Support clavier et gestes
- **VoiceOver**: Labels descriptifs

## 🧪 Tests Onboarding

### Tests Unitaires
```dart
void main() {
  group('OnboardingProvider', () {
    test('should start at page 0', () {
      final provider = OnboardingProvider();
      expect(provider.currentPage, 0);
    });

    test('should navigate to next page', () {
      final provider = OnboardingProvider();
      provider.nextPage();
      expect(provider.currentPage, 1);
    });

    test('should save preferences', () async {
      final provider = OnboardingProvider();
      provider.setPreference('notifications', true);

      await provider.completeOnboarding();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications'), true);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
