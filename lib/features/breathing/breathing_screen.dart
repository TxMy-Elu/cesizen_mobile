import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/exercise_repository.dart';
import 'package:cesizen_mobile/core/models/exercice_dto.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/core/theme/app_theme.dart';
import 'package:cesizen_mobile/core/widgets/cesizen_cards.dart';

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
  static const int _tickMs = 40;

  List<ExerciceDto> _exercises = [];
  ExerciceDto? _selected;
  bool _loading = true;
  String? _errorMessage;
  bool _sending = false;
  bool _isRunning = false;
  Timer? _sessionTimer;
  int _sessions = 0;
  int _elapsedMs = 0;
  int _phaseElapsedMs = 0;
  BreathingPhase _phase = BreathingPhase.inspiration;

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
      if (!mounted) {
        return;
      }
      setState(() {
        _exercises = exercises;
        _selected = exercises.isNotEmpty ? exercises.first : null;
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
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
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
                  onPressed: _loadExercises,
                  child: const Text('Reessayer'),
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
          title: 'Respiration guidee',
          subtitle:
              'Choisis un exercice, lance la session puis suis le cercle et le timer.',
          actions: [
            FilledButton.icon(
              onPressed: _sending ? null : _toggleSession,
              icon: Icon(_isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: _sending
                  ? const Text('Envoi...')
                  : Text(_isRunning ? 'Terminer la session' : 'Demarrer la session'),
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
                  if (_isRunning) {
                    return;
                  }
                  _selected = exercise;
                  _resetSessionVisuals();
                }),
                leading: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? CesizenColors.primary : null,
                ),
                title: Text(exercise.nom),
                subtitle: Text(
                  '${exercise.dureeInspiration}s inspire, ${exercise.dureeApnee}s pause, ${exercise.dureeExpiration}s expire',
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
              'Sessions completes: $_sessions\n'
              'Dernier exercice: ${_selected?.nom ?? 'Aucun'}\n'
              'Duree session courante: ${_formatDuration(_elapsedMs)}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingAnimationCard() {
    final selected = _selected;
    final phaseDuration = selected == null ? 1 : _phaseDurationFor(_phase, selected);
    final safeDuration = phaseDuration <= 0 ? 1 : phaseDuration;
    final phaseDurationMs = safeDuration * 1000;
    final phaseProgress = (_phaseElapsedMs / phaseDurationMs).clamp(0.0, 1.0);
    final remainingMs = (phaseDurationMs - _phaseElapsedMs).clamp(0, phaseDurationMs);
    final remaining = (remainingMs / 1000).ceil();

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
              'Secondes phase: $remaining / $safeDuration',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              width: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                        _isRunning ? '$remaining' : 'ZEN',
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Timer global: ${_formatDuration(_elapsedMs)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSession() async {
    if (_isRunning) {
      await _stopSessionAndRecord();
      return;
    }
    _startSession();
  }

  void _startSession() {
    final selected = _selected;
    if (selected == null) {
      return;
    }

    _sessionTimer?.cancel();
    setState(() {
      _isRunning = true;
      _phase = BreathingPhase.inspiration;
      _elapsedMs = 0;
      _phaseElapsedMs = 0;
      _normalizePhaseForExercise(selected);
    });

    _sessionTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) {
      if (!mounted || !_isRunning) {
        return;
      }
      final current = _selected;
      if (current == null) {
        return;
      }

      setState(() {
        _elapsedMs += _tickMs;
        _phaseElapsedMs += _tickMs;

        final phaseDurationMs = _phaseDurationFor(_phase, current) * 1000;
        if (phaseDurationMs > 0 && _phaseElapsedMs >= phaseDurationMs) {
          _moveToNextPhase(current);
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
    if (selected == null) {
      return;
    }

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
      if (!mounted) {
        return;
      }
      final label = widget.session.isAuthenticated ? 'enregistre' : 'termine localement';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session $label avec ${selected.nom}.'),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
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
      if (_phaseDurationFor(_phase, exercise) > 0) {
        return;
      }
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
    final totalSeconds = totalMs ~/ 1000;
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
