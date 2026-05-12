import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/exercise_repository.dart';
import 'package:cesizen_mobile/core/models/exercice_dto.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/core/theme/app_theme.dart';
import 'package:cesizen_mobile/core/widgets/cesizen_cards.dart';

const int _tickMs = 40;

String _formatSessionLabel(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0 ? '$m min' : '${m}min ${s}s';
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({
    super.key,
    required this.session,
    required this.exerciseRepository,
  });

  final UserSession session;
  final ExerciseRepository exerciseRepository;

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  List<ExerciceDto> _exercises = [];
  ExerciceDto? _selected;
  bool _loading = true;
  String? _errorMessage;
  bool _sending = false;
  bool _isRunning = false;
  Timer? _sessionTimer;
  int _sessions = 0;

  /// Temps écoulé en ms (interne)
  int _elapsedMs = 0;

  /// Durée max choisie par l'utilisateur (en ms)
  int _maxDurationMs = 120 * 1000; // défaut 2 min

  int _phaseElapsedMs = 0;
  BreathingPhase _phase = BreathingPhase.inspiration;

  /// Temps restant en ms (affiché à l'utilisateur)
  int get _remainingMs => (_maxDurationMs - _elapsedMs).clamp(0, _maxDurationMs);

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final exercises = await widget.exerciseRepository.fetchExercises();
      if (!mounted) return;
      setState(() {
        _exercises = exercises;
        _selected = exercises.isNotEmpty ? exercises.first : null;
        if (exercises.isNotEmpty) {
          _maxDurationMs = exercises.first.dureeSession * 1000;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

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
                  onPressed: _loadExercises,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        HeroCard(
          title: 'Respiration guidée',
          subtitle: 'Choisis un exercice et lance la session.',
          actions: [
            FilledButton.icon(
              onPressed: _sending ? null : _toggleSession,
              icon: Icon(_isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: _sending
                  ? const Text('Envoi...')
                  : Text(_isRunning ? 'Terminer la session' : 'Démarrer la session'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBreathingAnimationCard(),
        const SizedBox(height: 16),
        const Text(
          'Exercices disponibles',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ..._exercises.map((exercise) {
          final selected = _selected?.idExercice == exercise.idExercice;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                onTap: () => setState(() {
                  if (_isRunning) return;
                  _selected = exercise;
                  _maxDurationMs = exercise.dureeSession * 1000;
                  _resetSessionVisuals();
                }),
                leading: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? CesizenColors.primary : null,
                ),
                title: Text(exercise.nom),
                subtitle: Text(
                  '${exercise.dureeInspiration}s inspire · '
                  '${exercise.dureeApnee}s pause · '
                  '${exercise.dureeExpiration}s expire',
                ),
              ),
            ),
          );
        }),
        Card(
          color: CesizenColors.surfaceMuted,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sessions complétées : $_sessions\n'
              'Exercice : ${_selected?.nom ?? 'Aucun'}',
            ),
          ),
        ),
      ],
    );
  }

  // ── Animation de respiration ────────────────────────────────────────────────

  Widget _buildBreathingAnimationCard() {
    final selected = _selected;
    final phaseDuration = selected == null ? 1 : _phaseDurationFor(_phase, selected);
    final safeDuration = phaseDuration <= 0 ? 1 : phaseDuration;
    final phaseDurationMs = safeDuration * 1000;
    final phaseProgress = (_phaseElapsedMs / phaseDurationMs).clamp(0.0, 1.0);
    final phaseRemainingMs = (phaseDurationMs - _phaseElapsedMs).clamp(0, phaseDurationMs);
    final phaseRemaining = (phaseRemainingMs / 1000).ceil();

    // Progression globale (pour la barre de fond)
    final globalProgress = (_elapsedMs / _maxDurationMs).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              _phaseLabel(_phase),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Phase : $phaseRemaining / $safeDuration s',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              width: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de phase
                  SizedBox(
                    width: 236,
                    height: 236,
                    child: CircularProgressIndicator(
                      value: phaseProgress,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE3EBE2),
                      valueColor: const AlwaysStoppedAnimation<Color>(CesizenColors.primary),
                    ),
                  ),
                  // Bulle centrale
                  AnimatedContainer(
                    duration: const Duration(milliseconds: _tickMs),
                    curve: Curves.linear,
                    width: _circleSizeForPhase(phaseProgress),
                    height: _circleSizeForPhase(phaseProgress),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9BC7AA), Color(0xFF4B6B59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _isRunning ? '$phaseRemaining' : 'ZEN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Timer global décompte ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: CesizenColors.primary),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(_remainingMs),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _remainingMs <= 10000 && _isRunning
                        ? Colors.red.shade600
                        : CesizenColors.foreground,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ ${_formatSessionLabel(_maxDurationMs ~/ 1000)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A9A87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Barre de progression globale
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: globalProgress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE3EBE2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _remainingMs <= 10000 && _isRunning
                      ? Colors.red.shade400
                      : CesizenColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logique de session ──────────────────────────────────────────────────────

  Future<void> _toggleSession() async {
    if (_isRunning) {
      await _stopSessionAndRecord();
      return;
    }
    _startSession();
  }

  void _startSession() {
    final selected = _selected;
    if (selected == null) return;

    _sessionTimer?.cancel();
    setState(() {
      _isRunning = true;
      _phase = BreathingPhase.inspiration;
      _elapsedMs = 0;
      _phaseElapsedMs = 0;
      _normalizePhaseForExercise(selected);
    });

    _sessionTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) {
      if (!mounted || !_isRunning) return;
      final current = _selected;
      if (current == null) return;

      setState(() {
        _elapsedMs += _tickMs;
        _phaseElapsedMs += _tickMs;

        final phaseDurationMs = _phaseDurationFor(_phase, current) * 1000;
        if (phaseDurationMs > 0 && _phaseElapsedMs >= phaseDurationMs) {
          _moveToNextPhase(current);
        }

        // Arrêt automatique quand le décompte atteint 0
        if (_elapsedMs >= _maxDurationMs) {
          _elapsedMs = _maxDurationMs;
          _isRunning = false;
          _sessionTimer?.cancel();
          _recordSession().then((_) => _resetSessionVisuals());
        }
      });
    });
  }

  Future<void> _stopSessionAndRecord() async {
    _sessionTimer?.cancel();
    setState(() => _isRunning = false);

    if (_elapsedMs <= 0) {
      _resetSessionVisuals();
      return;
    }

    await _recordSession();
    _resetSessionVisuals();
  }

  Future<void> _recordSession() async {
    final selected = _selected;
    if (selected == null) return;

    setState(() => _sending = true);

    try {
      final userId = widget.session.userIdNumber;
      final token = widget.session.authToken;
      if (widget.session.isAuthenticated && userId != null && token != null) {
        await widget.exerciseRepository.recordSession(
          userId: userId,
          exerciceId: selected.idExercice,
          token: token,
          completedAt: DateTime.now().toUtc(),
        );
      }

      setState(() => _sessions++);
      widget.session.registerBreathingSession();
      if (!mounted) return;
      final label = widget.session.isAuthenticated ? 'enregistrée' : 'terminée localement';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session $label avec ${selected.nom}.')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _moveToNextPhase(ExerciceDto exercise) {
    _phase = switch (_phase) {
      BreathingPhase.inspiration => BreathingPhase.apnee,
      BreathingPhase.apnee => BreathingPhase.expiration,
      BreathingPhase.expiration => BreathingPhase.inspiration,
    };
    _phaseElapsedMs = 0;
    _normalizePhaseForExercise(exercise);
  }

  void _normalizePhaseForExercise(ExerciceDto exercise) {
    for (var i = 0; i < 3; i++) {
      if (_phaseDurationFor(_phase, exercise) > 0) return;
      _phase = switch (_phase) {
        BreathingPhase.inspiration => BreathingPhase.apnee,
        BreathingPhase.apnee => BreathingPhase.expiration,
        BreathingPhase.expiration => BreathingPhase.inspiration,
      };
    }
  }

  int _phaseDurationFor(BreathingPhase phase, ExerciceDto exercise) {
    return switch (phase) {
      BreathingPhase.inspiration => exercise.dureeInspiration,
      BreathingPhase.apnee => exercise.dureeApnee,
      BreathingPhase.expiration => exercise.dureeExpiration,
    };
  }

  double _circleSizeForPhase(double phaseProgress) {
    const minSize = 120.0;
    const maxSize = 180.0;
    return switch (_phase) {
      BreathingPhase.inspiration => minSize + (maxSize - minSize) * phaseProgress,
      BreathingPhase.apnee => maxSize,
      BreathingPhase.expiration => maxSize - (maxSize - minSize) * phaseProgress,
    };
  }

  String _phaseLabel(BreathingPhase phase) {
    return switch (phase) {
      BreathingPhase.inspiration => 'Inspire',
      BreathingPhase.apnee => 'Pause',
      BreathingPhase.expiration => 'Expire',
    };
  }

  String _formatDuration(int totalMs) {
    final totalSeconds = (totalMs / 1000).ceil().clamp(0, _maxDurationMs ~/ 1000);
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resetSessionVisuals() {
    setState(() {
      _elapsedMs = 0;
      _phaseElapsedMs = 0;
      _phase = BreathingPhase.inspiration;
    });
  }
}

enum BreathingPhase { inspiration, apnee, expiration }
