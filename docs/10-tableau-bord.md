# 📊 Tableau de Bord - CESIZen Mobile

## 🎯 Vue d'Ensemble

Le tableau de bord offre une vue d'ensemble complète de l'activité utilisateur avec statistiques, graphiques et recommandations personnalisées.

### Fonctionnalités Clés
- ✅ Métriques clés en temps réel
- ✅ Graphiques d'évolution
- ✅ Historique des activités
- ✅ Recommandations personnalisées
- ✅ Badges et récompenses

## 📊 Métriques du Dashboard

### Métriques Principales
```dart
class DashboardMetrics {
  final int totalSessions;           // Sessions totales
  final Duration totalBreathingTime; // Temps total respiration
  final int articlesRead;            // Articles lus
  final int currentStreak;           // Série actuelle (jours)
  final int longestStreak;           // Plus longue série
  final double averageSessionQuality; // Qualité moyenne
  final int weeklyGoalProgress;      // Progression objectif hebdo
  final DateTime lastActivity;       // Dernière activité
}
```

### Statistiques Détaillées
```dart
class DetailedStats {
  final Map<String, int> sessionsByCategory;     // Par catégorie
  final Map<String, Duration> timeByCategory;    // Temps par catégorie
  final List<DailyStats> dailyStats;             // Stats journalières
  final List<WeeklyStats> weeklyStats;           // Stats hebdomadaires
  final Map<String, int> achievements;           // Réalisations
  final List<Milestone> milestones;              // Jalons atteints
}
```

## 🎨 Écran Dashboard

### Wireframe Principal
```
┌─────────────────────────────────┐
│  🏠 Tableau de Bord             │
│                                 │
│  ┌─────────────────────────┐    │
│  │ Bonjour, [Nom] !        │    │
│  │ Série: 7 jours 🔥       │    │
│  └─────────────────────────┘    │
│                                 │
│  ┌─┬─┬─┐  Métriques Clés        │
│  │📊│⏰│  24 sess • 180 min     │
│  │24│180│  12 articles lus      │
│  └─┴─┴─┘                        │
│                                 │
│  📈 Graphique Évolution         │
│  ████████░░░░░░ 75% objectif    │
│                                 │
│  🏆 Réalisations Récentes       │
│  🥇 Première semaine complète   │
│  🥈 10 sessions d'affilée       │
│                                 │
│  💡 Recommandations             │
│  Essayez "Respiration 4-7-8"    │
│  Lisez "Gestion du stress"      │
└─────────────────────────────────┘
```

### Implémentation Dashboard
```dart
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardMetrics? _metrics;
  DetailedStats? _detailedStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final dashboardProvider = context.read<DashboardProvider>();
      _metrics = await dashboardProvider.getMetrics();
      _detailedStats = await dashboardProvider.getDetailedStats();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement dashboard')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_metrics == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur de chargement')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête personnalisé
              _buildWelcomeHeader(),

              const SizedBox(height: 24),

              // Métriques clés
              _buildKeyMetrics(),

              const SizedBox(height: 24),

              // Graphique évolution
              _buildProgressChart(),

              const SizedBox(height: 24),

              // Objectif hebdomadaire
              _buildWeeklyGoal(),

              const SizedBox(height: 24),

              // Réalisations récentes
              _buildRecentAchievements(),

              const SizedBox(height: 24),

              // Recommandations
              _buildRecommendations(),

              const SizedBox(height: 24),

              // Activité récente
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final userName = context.read<AuthProvider>().state.user?.name ?? 'Utilisateur';
    final greeting = _getGreeting();
    final streakText = _metrics!.currentStreak > 0
        ? 'Série: ${_metrics!.currentStreak} jours 🔥'
        : 'Commencez votre série !';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName !',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streakText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.play_circle_filled,
            value: '${_metrics!.totalSessions}',
            label: 'Sessions',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.timer,
            value: '${_metrics!.totalBreathingTime.inMinutes}',
            label: 'Minutes',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.article,
            value: '${_metrics!.articlesRead}',
            label: 'Articles',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution sur 7 jours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _detailedStats != null
                  ? SessionsChart(stats: _detailedStats!.dailyStats)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGoal() {
    final progress = _metrics!.weeklyGoalProgress / 100.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Objectif Hebdomadaire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_metrics!.weeklyGoalProgress}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '7 sessions par semaine',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    if (_detailedStats == null || _detailedStats!.achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Réalisations Récentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._detailedStats!.achievements.entries.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getAchievementText(entry.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x${entry.value}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Recommandations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              icon: Icons.spa,
              title: 'Essayez la Respiration 4-7-8',
              subtitle: 'Exercice anti-stress éprouvé',
              onTap: () => _navigateToExercise('4-7-8'),
            ),
            const SizedBox(height: 8),
            _buildRecommendationItem(
              icon: Icons.article,
              title: 'Lisez "Gestion du stress"',
              subtitle: 'Article recommandé pour vous',
              onTap: () => _navigateToArticle('stress-management'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activité Récente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/activity-history'),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Placeholder pour activité récente
            const Center(
              child: Text(
                'Aucune activité récente',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getAchievementText(String achievementKey) {
    switch (achievementKey) {
      case 'first_session':
        return 'Première session terminée';
      case 'week_streak':
        return 'Première semaine complète';
      case 'ten_sessions':
        return '10 sessions d\'affilée';
      default:
        return achievementKey;
    }
  }

  void _navigateToExercise(String exerciseId) {
    // Navigation vers exercice spécifique
    Navigator.pushNamed(context, '/exercise-detail', arguments: exerciseId);
  }

  void _navigateToArticle(String articleId) {
    // Navigation vers article spécifique
    Navigator.pushNamed(context, '/article-detail', arguments: articleId);
  }
}
```

## 📈 Graphiques et Visualisations

### SessionsChart Widget
```dart
class SessionsChart extends StatelessWidget {
  final List<DailyStats> stats;

  const SessionsChart({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < stats.length) {
                  final date = stats[index].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: stats.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.sessionsCount.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
```

### Circular Progress Widget
```dart
class CircularProgressWithText extends StatelessWidget {
  final double progress;
  final String text;
  final Color color;

  const CircularProgressWithText({
    Key? key,
    required this.progress,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 8,
          ),
          Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔄 Provider Dashboard

### DashboardProvider
```dart
class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;
  final LocalStorageService _localStorage;

  DashboardMetrics? _metrics;
  DetailedStats? _detailedStats;

  DashboardProvider(this._repository, this._localStorage);

  Future<DashboardMetrics> getMetrics() async {
    try {
      // Essayer de charger depuis le cache local d'abord
      final cached = await _localStorage.getCachedMetrics();
      if (cached != null) {
        _metrics = cached;
        // Charger en arrière-plan depuis serveur
        _syncMetricsFromServer();
        return cached;
      }

      // Charger depuis serveur
      _metrics = await _repository.getMetrics();
      await _localStorage.cacheMetrics(_metrics!);
      return _metrics!;
    } catch (e) {
      // Fallback vers données locales
      final local = await _localStorage.getLocalMetrics();
      _metrics = local;
      return local;
    }
  }

  Future<DetailedStats> getDetailedStats() async {
    try {
      _detailedStats = await _repository.getDetailedStats();
      return _detailedStats!;
    } catch (e) {
      // Fallback vers stats locales
      final local = await _localStorage.getLocalDetailedStats();
      _detailedStats = local;
      return local;
    }
  }

  Future<void> _syncMetricsFromServer() async {
    try {
      final serverMetrics = await _repository.getMetrics();
      await _localStorage.cacheMetrics(serverMetrics);
      _metrics = serverMetrics;
      notifyListeners();
    } catch (e) {
      // Ignorer erreur de sync
    }
  }

  Future<void> refreshData() async {
    await _syncMetricsFromServer();
    _detailedStats = await _repository.getDetailedStats();
    notifyListeners();
  }

  // Calculer recommandations personnalisées
  Future<List<String>> getPersonalizedRecommendations() async {
    if (_metrics == null) return [];

    final recommendations = <String>[];

    // Basé sur la série actuelle
    if (_metrics!.currentStreak < 3) {
      recommendations.add('continue_streak');
    }

    // Basé sur les sessions
    if (_metrics!.totalSessions < 5) {
      recommendations.add('try_beginner_exercise');
    }

    // Basé sur les articles
    if (_metrics!.articlesRead < 3) {
      recommendations.add('read_stress_article');
    }

    return recommendations;
  }
}
```

## 🏆 Système de Réalisations

### Achievement System
```dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int points;
  final AchievementType type;
  final Map<String, dynamic> criteria;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}

enum AchievementType {
  sessions,
  streak,
  time,
  articles,
  special,
}

class AchievementService {
  final LocalStorageService _localStorage;

  AchievementService(this._localStorage);

  Future<List<Achievement>> getAchievements() async {
    final userStats = await _localStorage.getUserStats();
    final unlockedAchievements = await _localStorage.getUnlockedAchievements();

    return _allAchievements.map((achievement) {
      final isUnlocked = _checkAchievementUnlocked(
        achievement,
        userStats,
        unlockedAchievements,
      );

      return achievement.copyWith(isUnlocked: isUnlocked);
    }).toList();
  }

  bool _checkAchievementUnlocked(
    Achievement achievement,
    Map<String, dynamic> userStats,
    List<String> unlocked,
  ) {
    if (unlocked.contains(achievement.id)) return true;

    switch (achievement.type) {
      case AchievementType.sessions:
        return userStats['totalSessions'] >= achievement.criteria['count'];
      case AchievementType.streak:
        return userStats['currentStreak'] >= achievement.criteria['days'];
      case AchievementType.time:
        return userStats['totalMinutes'] >= achievement.criteria['minutes'];
      case AchievementType.articles:
        return userStats['articlesRead'] >= achievement.criteria['count'];
      default:
        return false;
    }
  }

  Future<void> checkAndUnlockAchievements(DashboardMetrics metrics) async {
    final achievements = await getAchievements();
    final userStats = await _localStorage.getUserStats();

    for (final achievement in achievements) {
      if (!achievement.isUnlocked &&
          _checkAchievementUnlocked(achievement, userStats, [])) {
        await _unlockAchievement(achievement);
      }
    }
  }

  Future<void> _unlockAchievement(Achievement achievement) async {
    await _localStorage.unlockAchievement(achievement.id);

    // Notification de réussite
    // TODO: Implémenter notification push
  }
}
```

## 🧪 Tests Dashboard

### Tests Unitaires
```dart
void main() {
  group('DashboardProvider', () {
    test('should load metrics successfully', () async {
      final mockRepo = MockDashboardRepository();
      final provider = DashboardProvider(mockRepo, mockStorage);

      when(mockRepo.getMetrics()).thenAnswer((_) async => mockMetrics);

      final metrics = await provider.getMetrics();

      expect(metrics.totalSessions, mockMetrics.totalSessions);
    });

    test('should handle network errors gracefully', () async {
      final mockRepo = MockDashboardRepository();
      final provider = DashboardProvider(mockRepo, mockStorage);

      when(mockRepo.getMetrics()).thenThrow(Exception('Network error'));
      when(mockStorage.getLocalMetrics()).thenAnswer((_) async => mockMetrics);

      final metrics = await provider.getMetrics();

      expect(metrics.totalSessions, mockMetrics.totalSessions);
    });
  });

  group('AchievementService', () {
    test('should unlock achievement when criteria met', () async {
      final service = AchievementService(mockStorage);

      when(mockStorage.getUserStats()).thenAnswer((_) async => {
        'totalSessions': 10,
      });

      final achievements = await service.getAchievements();
      final firstSessionAchievement = achievements
          .firstWhere((a) => a.id == 'first_session');

      expect(firstSessionAchievement.isUnlocked, true);
    });
  });
}
```

---

*Dernière mise à jour: 21 avril 2026*
