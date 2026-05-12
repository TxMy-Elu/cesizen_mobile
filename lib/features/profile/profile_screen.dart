import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/auth_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/consultation_repository.dart';
import 'package:cesizen_mobile/core/data/repositories/exercise_repository.dart';
import 'package:cesizen_mobile/core/models/consulter_dto.dart';
import 'package:cesizen_mobile/core/models/exercer_dto.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/core/widgets/cesizen_cards.dart';
import 'package:cesizen_mobile/features/auth/login_screen.dart';
import 'package:cesizen_mobile/features/auth/register_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.session,
    required this.authRepository,
    required this.exerciseRepository,
    required this.consultationRepository,
    required this.onSessionChanged,
  });

  final UserSession session;
  final AuthRepository authRepository;
  final ExerciseRepository exerciseRepository;
  final ConsultationRepository consultationRepository;
  final VoidCallback onSessionChanged;

  @override
  Widget build(BuildContext context) {
    if (!session.isAuthenticated) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off_rounded, size: 36),
                const SizedBox(height: 10),
                const Text('Vous êtes en mode anonyme.'),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          session: session,
                          authRepository: authRepository,
                        ),
                      ),
                    );
                    onSessionChanged();
                  },
                  child: const Text('Se connecter'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(
                          session: session,
                          authRepository: authRepository,
                        ),
                      ),
                    );
                    onSessionChanged();
                  },
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _AuthenticatedProfileView(
      session: session,
      exerciseRepository: exerciseRepository,
      consultationRepository: consultationRepository,
      onLogout: () {
        session.logout();
        onSessionChanged();
      },
    );
  }
}

class _AuthenticatedProfileView extends StatefulWidget {
  const _AuthenticatedProfileView({
    required this.session,
    required this.exerciseRepository,
    required this.consultationRepository,
    required this.onLogout,
  });

  final UserSession session;
  final ExerciseRepository exerciseRepository;
  final ConsultationRepository consultationRepository;
  final VoidCallback onLogout;

  @override
  State<_AuthenticatedProfileView> createState() => _AuthenticatedProfileViewState();
}

class _AuthenticatedProfileViewState extends State<_AuthenticatedProfileView> {
  bool _loading = true;
  String? _errorMessage;
  List<ExercerDto> _sessions = [];
  List<ConsulterDto> _consultations = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = widget.session.userIdNumber;
    final token = widget.session.authToken;
    if (userId == null || token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'Session authentifiée invalide.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.exerciseRepository.fetchUserSessions(userId: userId, token: token),
        widget.consultationRepository.fetchUserConsultations(
          userId: userId,
          token: token,
        ),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _sessions = results[0] as List<ExercerDto>;
        _consultations = results[1] as List<ConsulterDto>;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loadProfile,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sessionsCompleted = _sessions.where((item) => item.completedAt != null).length;
    final articleViewsTotal = _consultations.length;
    final uniqueArticlesRead = _consultations.map((item) => item.idArticle).toSet().length;
    final latestSession = _sessions
        .map((item) => item.completedAt)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (current, next) {
      if (current == null || next.isAfter(current)) {
        return next;
      }
      return current;
    });

    final now = DateTime.now().toUtc();
    final daysSinceLastSession = latestSession == null
        ? 0
        : now.difference(latestSession).inDays.clamp(0, 9999);

    final streakDays = _computeStreak(_sessions);

    final activityStats = [
      ('Sessions totales', '${_sessions.length}', 'Séances de respiration enregistrées'),
      ('Sessions complétées', '$sessionsCompleted', 'Séances menées jusqu\'au bout'),
      ('Série active', '$streakDays jour(s)', 'Jours consécutifs de pratique'),
      ('Dernière session', 'Il y a $daysSinceLastSession jour(s)', 'Date de la dernière séance'),
      ('Vues articles', '$articleViewsTotal', 'Lectures d\'articles de prévention'),
      ('Articles uniques', '$uniqueArticlesRead', 'Articles distincts consultés'),
    ];

    final historySessions = [..._sessions]
      ..sort((a, b) {
        final left = a.completedAt?.millisecondsSinceEpoch ?? 0;
        final right = b.completedAt?.millisecondsSinceEpoch ?? 0;
        return right.compareTo(left);
      });

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        HeroCard(
          title: widget.session.userName,
          subtitle: widget.session.email,
          actions: [
            OutlinedButton.icon(
              onPressed: () {
                widget.onLogout();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Session fermée.')));
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SectionCard(
          icon: Icons.air_rounded,
          title: 'Sessions respiration',
          content: '$sessionsCompleted session(s) enregistre(e)s.',
        ),
        const SizedBox(height: 12),
        SectionCard(
          icon: Icons.visibility_rounded,
          title: 'Articles consultés',
          content: '$articleViewsTotal lecture(s) de prévention.',
        ),
        const SizedBox(height: 12),
        SectionCard(
          icon: Icons.badge_rounded,
          title: 'Compte',
          content:
              'Rôle: ${widget.session.role}\nConsentement RGPD: ${widget.session.rgpdConsent ? 'Oui' : 'Non'}\nCréé le: ${widget.session.createdAt}',
        ),
        const SizedBox(height: 12),
        const Text(
          'Statistiques activité',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...activityStats.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                title: Text(item.$1),
                subtitle: Text(item.$3),
                trailing: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique respiration',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Affichage en heure locale',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                if (historySessions.isEmpty)
                  const Text('Aucune session pour le moment.'),
                ...historySessions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE3EBE2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _formatLocalDateTime(item.completedAt),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.exercice.nom,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HistoryPill(
                                icon: Icons.north_rounded,
                                label: 'Inspire ${item.exercice.dureeInspiration}s',
                              ),
                              _HistoryPill(
                                icon: Icons.pause_rounded,
                                label: 'Pause ${item.exercice.dureeApnee}s',
                              ),
                              _HistoryPill(
                                icon: Icons.south_rounded,
                                label: 'Expire ${item.exercice.dureeExpiration}s',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _computeStreak(List<ExercerDto> sessions) {
    final uniqueDays = sessions
        .map((item) => item.completedAt)
        .whereType<DateTime>()
        .map((item) => item.toUtc().toIso8601String().substring(0, 10))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) {
      return 0;
    }

    var streak = 1;
    for (var index = 1; index < uniqueDays.length; index++) {
      final previous = DateTime.parse('${uniqueDays[index - 1]}T00:00:00Z');
      final current = DateTime.parse('${uniqueDays[index]}T00:00:00Z');
      if (previous.difference(current).inDays == 1) {
        streak += 1;
      } else {
        break;
      }
    }

    return streak;
  }

  String _formatLocalDateTime(DateTime? value) {
    if (value == null) {
      return 'Date indisponible';
    }
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year a $hour:$minute';
  }
}

class _HistoryPill extends StatelessWidget {
  const _HistoryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3EBE2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
