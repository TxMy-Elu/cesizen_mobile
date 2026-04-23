# 🫁 Exercices de Respiration - CESIZen Mobile

## 🎯 Vue d'Ensemble

Le module Exercices propose des séances de respiration guidées avec minuteur intégré, suivi de progression et personnalisation.

### Fonctionnalités Clés
- ✅ Exercices guidés avec audio/visuel
- ✅ Minuteur intégré avec phases
- ✅ Suivi progression et statistiques
- ✅ Mode hors-ligne complet
- ✅ Exercices personnalisables

## 📊 Modèle de Données Exercices

### Exercice
```dart
class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final String category; // 'stress', 'sleep', 'focus', 'energy'
  final Difficulty difficulty;
  final Duration totalDuration;
  final List<BreathingPhase> phases;
  final String audioUrl;
  final String animationType;
  final int recommendedSessions;
  final List<String> benefits;
  final bool isPremium;

  // Statistiques
  final int completionCount;
  final double averageRating;
  final Duration averageCompletionTime;
}

enum Difficulty { beginner, intermediate, advanced }

class BreathingPhase {
  final String name;
  final String instruction;
  final Duration duration;
  final BreathingAction action; // inhale, exhale, hold
  final Color color;
  final String audioCue;
}

enum BreathingAction { inhale, exhale, hold }
```

### Session
```dart
class BreathingSession {
  final String id;
  final String exerciseId;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration actualDuration;
  final int completedPhases;
  final SessionQuality quality; // poor, good, excellent
  final Map<String, dynamic> metrics; // rythme cardiaque, etc.
  final String notes;

  bool get isCompleted => endTime != null;
}

enum SessionQuality { poor, good, excellent }
```

## 🎨 Écran Liste Exercices

### Wireframe Exercices
```
┌─────────────────────────────────┐
│  🫁 Exercices                   │
│                                 │
│  ┌─────────────────────────┐    │
│  │ 🔍 Rechercher...        │    │
│  └─────────────────────────┘    │
│                                 │
│  📂 Catégories ▼                │
│  ┌─────────────────────────┐    │
│  │ 😌 Anti-Stress          │    │
│  │ 😴 Sommeil              │    │
│  │ 🎯 Concentration        │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─────────────────────────┐    │
│  │ [Animation cercle]      │    │
│  │ Respiration 4-7-8       │    │
│  │ Anti-stress éprouvé     │    │
│  │ ⭐ 4.8 • 4 min • 12 sess│    │
│  └─────────────────────────┘    │
│                                 │
│  [Mes Statistiques ▼]           │
└─────────────────────────────────┘
```

### Implémentation Liste
```dart
class ExercisesListScreen extends StatefulWidget {
  const ExercisesListScreen({Key? key}) : super(key: key);

  @override
  _ExercisesListScreenState createState() => _ExercisesListScreenState();
}

class _ExercisesListScreenState extends State<ExercisesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<BreathingExercise> _exercises = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _selectedCategory;
  String _searchQuery = '';
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);

    try {
      final exercisesProvider = context.read<ExercisesProvider>();
      _exercises = await exercisesProvider.getExercises(
        category: _selectedCategory,
        searchQuery: _searchQuery,
      );

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement exercices')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final exercisesProvider = context.read<ExercisesProvider>();
      _categories = await exercisesProvider.getCategories();
      setState(() {});
    } catch (e) {
      // Gestion erreur silencieuse
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() => _searchQuery = query);
      _debounceSearch();
    }
  }

  Timer? _searchTimer;
  void _debounceSearch() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _loadExercises();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices'),
        actions: [
          IconButton(
            icon: Icon(_showStats ? Icons.list : Icons.bar_chart),
            onPressed: () => setState(() => _showStats = !_showStats),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filtres catégories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: _selectedCategory == null,
                  onSelected: (_) {
                    setState(() => _selectedCategory = null);
                    _loadExercises();
                  },
                ),
                const SizedBox(width: 8),
                ..._categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryDisplayName(category)),
                    selected: _selectedCategory == category,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                      _loadExercises();
                    },
                  ),
                )),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: _showStats ? _buildStatsView() : _buildExercisesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/custom-exercise'),
        child: const Icon(Icons.add),
        tooltip: 'Créer exercice personnalisé',
      ),
    );
  }

  Widget _buildExercisesList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _exercises.isEmpty
            ? const Center(
                child: Text('Aucun exercice trouvé'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ExerciseCard(
                    exercise: exercise,
                    onTap: () => _startExercise(exercise),
                  );
                },
              );
  }

  Widget _buildStatsView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<ExercisesProvider>().getUserStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard(
              'Total Sessions',
              '${stats['totalSessions']}',
              Icons.play_circle_filled,
              Colors.blue,
            ),
            _buildStatCard(
              'Temps Total',
              '${stats['totalMinutes']} min',
              Icons.timer,
              Colors.green,
            ),
            _buildStatCard(
              'Exercices Complétés',
              '${stats['completedExercises']}',
              Icons.check_circle,
              Colors.orange,
            ),
            _buildStatCard(
              'Séquence Actuelle',
              '${stats['currentStreak']} jours',
              Icons.local_fire_department,
              Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startExercise(BreathingExercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BreathingSessionScreen(exercise: exercise),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'stress':
        return 'Anti-Stress';
      case 'sleep':
        return 'Sommeil';
      case 'focus':
        return 'Concentration';
      case 'energy':
        return 'Énergie';
      default:
        return category;
    }
  }
}
```

## 🃏 Composant Carte Exercice

### ExerciseCard Widget
```dart
class ExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onTap;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Animation/visualisation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getCategoryColors(exercise.category),
                  ),
                ),
                child: BreathingAnimation(
                  type: exercise.animationType,
                  isActive: false,
                ),
              ),

              const SizedBox(width: 16),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      exercise.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Métadonnées
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              exercise.averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Durée
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.totalDuration.inMinutes} min',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        // Sessions
                        Row(
                          children: [
                            const Icon(Icons.repeat, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.recommendedSessions}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Difficulté
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(exercise.difficulty).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getDifficultyText(exercise.difficulty),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getDifficultyColor(exercise.difficulty),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Bénéfices
                    Wrap(
                      spacing: 4,
                      children: exercise.benefits.take(2).map((benefit) => Chip(
                        label: Text(
                          benefit,
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue[50],
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ],
                ),
              ),

              // Indicateur premium
              if (exercise.isPremium) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryColors(String category) {
    switch (category) {
      case 'stress':
        return [Colors.blue[300]!, Colors.blue[600]!];
      case 'sleep':
        return [Colors.purple[300]!, Colors.purple[600]!];
      case 'focus':
        return [Colors.green[300]!, Colors.green[600]!];
      case 'energy':
        return [Colors.orange[300]!, Colors.orange[600]!];
      default:
        return [Colors.grey[300]!, Colors.grey[600]!];
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyText(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Débutant';
      case Difficulty.intermediate:
        return 'Intermédiaire';
      case Difficulty.advanced:
        return 'Avancé';
    }
  }
}
```

## 🫁 Écran Session de Respiration

### Wireframe Session
```
┌─────────────────────────────────┐
│  ← Respiration 4-7-8            │
│                                 │
│         [Cercle animé]          │
│                                 │
│         INSPIRER                │
│         4 secondes              │
│                                 │
│  ████████░░░░░░░░░░ 40%         │
│                                 │
│  [Pause] [Stop]                 │
│                                 │
│  Phase 2/4 • 2:30 restant      │
└─────────────────────────────────┘
```

### Implémentation Session
```dart
class BreathingSessionScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const BreathingSessionScreen({Key? key, required this.exercise}) : super(key: key);

  @override
  _BreathingSessionScreenState createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  int _currentPhaseIndex = 0;
  Duration _phaseTimeRemaining = Duration.zero;
  Duration _totalTimeRemaining = Duration.zero;
  bool _isPaused = false;
  bool _isCompleted = false;
  Timer? _phaseTimer;
  Timer? _totalTimer;
  DateTime _sessionStartTime = DateTime.now();

  late BreathingSession _currentSession;

  @override
  void initState() {
    super.initState();

    // Initialiser session
    _currentSession = BreathingSession(
      id: const Uuid().v4(),
      exerciseId: widget.exercise.id,
      startTime: _sessionStartTime,
    );

    // Animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Démarrer session
    _startSession();
  }

  void _startSession() {
    setState(() {
      _totalTimeRemaining = widget.exercise.totalDuration;
      _startPhase(0);
    });

    // Timer total
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _totalTimeRemaining -= const Duration(seconds: 1);
          if (_totalTimeRemaining.inSeconds <= 0) {
            _completeSession();
          }
        });
      }
    });
  }

  void _startPhase(int phaseIndex) {
    if (phaseIndex >= widget.exercise.phases.length) {
      _completeSession();
      return;
    }

    final phase = widget.exercise.phases[phaseIndex];
    setState(() {
      _currentPhaseIndex = phaseIndex;
      _phaseTimeRemaining = phase.duration;
    });

    // Timer phase
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _phaseTimeRemaining -= const Duration(seconds: 1);
          if (_phaseTimeRemaining.inSeconds <= 0) {
            _nextPhase();
          }
        });
      }
    });

    // Audio cue
    _playAudioCue(phase.audioCue);

    // Vibration (optionnel)
    HapticFeedback.lightImpact();
  }

  void _nextPhase() {
    _startPhase(_currentPhaseIndex + 1);
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);

    if (_isPaused) {
      _animationController.stop();
    } else {
      _animationController.repeat(reverse: true);
    }
  }

  void _stopSession() {
    _phaseTimer?.cancel();
    _totalTimer?.cancel();
    _animationController.stop();

    // Sauvegarder session incomplète
    _saveSession(completed: false);

    Navigator.pop(context);
  }

  void _completeSession() {
    _phaseTimer?.cancel();
    _totalTimer?.cancel();
    _animationController.stop();

    setState(() => _isCompleted = true);

    // Sauvegarder session complétée
    _saveSession(completed: true);

    // Afficher félicitations
    _showCompletionDialog();
  }

  Future<void> _saveSession({required bool completed}) async {
    final endTime = completed ? DateTime.now() : null;
    final actualDuration = DateTime.now().difference(_sessionStartTime);

    final completedSession = _currentSession.copyWith(
      endTime: endTime,
      actualDuration: actualDuration,
      completedPhases: completed ? widget.exercise.phases.length : _currentPhaseIndex,
      quality: _calculateSessionQuality(),
    );

    try {
      final exercisesProvider = context.read<ExercisesProvider>();
      await exercisesProvider.saveSession(completedSession);
    } catch (e) {
      // Gestion erreur silencieuse
    }
  }

  SessionQuality _calculateSessionQuality() {
    final completionRate = _currentPhaseIndex / widget.exercise.phases.length;
    if (completionRate >= 0.9) return SessionQuality.excellent;
    if (completionRate >= 0.6) return SessionQuality.good;
    return SessionQuality.poor;
  }

  Future<void> _playAudioCue(String audioCue) async {
    // Implémentation audio
    // Utiliser package audioplayers
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Vous avez terminé "${widget.exercise.name}"',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Session de ${widget.exercise.totalDuration.inMinutes} minutes complétée',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fermer dialog
              Navigator.pop(context); // Retour à la liste
            },
            child: const Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer dialog
              // Redémarrer même exercice
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BreathingSessionScreen(exercise: widget.exercise),
                ),
              );
            },
            child: const Text('Refaire'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _totalTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Session terminée !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPhase = widget.exercise.phases[_currentPhaseIndex];
    final progress = 1.0 - (_totalTimeRemaining.inSeconds / widget.exercise.totalDuration.inSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _stopSession,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Animation principale
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isPaused ? 1.0 : _scaleAnimation.value,
                        child: Opacity(
                          opacity: _isPaused ? 0.5 : _opacityAnimation.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  currentPhase.color.withOpacity(0.3),
                                  currentPhase.color,
                                ],
                              ),
                              boxShadow: _isPaused ? null : [
                                BoxShadow(
                                  color: currentPhase.color.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getActionText(currentPhase.action),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Text(
                currentPhase.instruction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                '${_phaseTimeRemaining.inSeconds} secondes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              // Barre de progression totale
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(currentPhase.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).round()}% • ${_formatDuration(_totalTimeRemaining)} restant',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Contrôles
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _togglePause,
                    backgroundColor: _isPaused ? Colors.green : Colors.orange,
                    child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  ),
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    onPressed: _stopSession,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.stop),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Informations phase
              Text(
                'Phase ${_currentPhaseIndex + 1}/${widget.exercise.phases.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActionText(BreathingAction action) {
    switch (action) {
      case BreathingAction.inhale:
        return 'INSPIRER';
      case BreathingAction.exhale:
        return 'EXPIRER';
      case BreathingAction.hold:
        return 'REtenir';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
```

## 🎨 Animation de Respiration

### BreathingAnimation Widget
```dart
class BreathingAnimation extends StatefulWidget {
  final String type;
  final bool isActive;

  const BreathingAnimation({
    Key? key,
    required this.type,
    this.isActive = true,
  }) : super(key: key);

  @override
  _BreathingAnimationState createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.7,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BreathingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
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
          scale: widget.isActive ? _animation.value : 1.0,
          child: CustomPaint(
            painter: _getPainter(widget.type),
            size: const Size(60, 60),
          ),
        );
      },
    );
  }

  CustomPainter _getPainter(String type) {
    switch (type) {
      case 'circle':
        return CircleBreathingPainter();
      case 'wave':
        return WaveBreathingPainter();
      case 'flower':
        return FlowerBreathingPainter();
      default:
        return CircleBreathingPainter();
    }
  }
}

class CircleBreathingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
```

## 🔄 Provider Exercices

### ExercisesProvider
```dart
class ExercisesProvider extends ChangeNotifier {
  final ExercisesRepository _repository;
  final LocalStorageService _localStorage;

  List<BreathingExercise> _exercises = [];
  bool _isLoading = false;

  ExercisesProvider(this._repository, this._localStorage);

  // Getters
  List<BreathingExercise> get exercises => _exercises;
  bool get isLoading => _isLoading;

  Future<List<BreathingExercise>> getExercises({
    String? category,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _repository.getExercises(
        category: category,
        searchQuery: searchQuery,
      );

      return _exercises;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      return ['stress', 'sleep', 'focus', 'energy']; // Fallback
    }
  }

  Future<void> saveSession(BreathingSession session) async {
    try {
      await _repository.saveSession(session);
      await _localStorage.saveSession(session);

      // Mettre à jour statistiques
      await _updateUserStats(session);
    } catch (e) {
      // Gestion erreur
    }
  }

  Future<void> _updateUserStats(BreathingSession session) async {
    final stats = await _localStorage.getUserStats();
    final updatedStats = Map<String, dynamic>.from(stats);

    updatedStats['totalSessions'] = (stats['totalSessions'] ?? 0) + 1;
    updatedStats['totalMinutes'] = (stats['totalMinutes'] ?? 0) +
        session.actualDuration.inMinutes;

    if (session.isCompleted) {
      updatedStats['completedExercises'] = (stats['completedExercises'] ?? 0) + 1;
    }

    await _localStorage.saveUserStats(updatedStats);
  }

  Future<Map<String, dynamic>> getUserStats() async {
    return await _localStorage.getUserStats();
  }

  Future<List<BreathingSession>> getSessionHistory() async {
    return await _localStorage.getSessionHistory();
  }
}
```

## 🧪 Tests Exercices

### Tests Unitaires
```dart
void main() {
  group('BreathingSessionScreen', () {
    testWidgets('starts session correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BreathingSessionScreen(exercise: mockExercise),
        ),
      );

      expect(find.text('INSPIRER'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('completes session successfully', (tester) async {
      // Test completion logic
    });
  });

  group('ExercisesProvider', () {
    test('should load exercises successfully', () async {
      final mockRepo = MockExercisesRepository();
      final provider = ExercisesProvider(mockRepo, mockStorage);

      when(mockRepo.getExercises()).thenAnswer((_) async => [mockExercise]);

      final exercises = await provider.getExercises();

      expect(exercises.length, 1);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
