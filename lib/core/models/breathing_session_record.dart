class BreathingSessionRecord {
  const BreathingSessionRecord({
    required this.id,
    required this.mode,
    required this.userId,
    required this.startedAt,
    required this.durationMin,
    required this.pattern,
    required this.haptics,
    required this.source,
    required this.completed,
    this.note,
  });

  final String id;
  final String mode;
  final String? userId;
  final String startedAt;
  final int durationMin;
  final String pattern;
  final bool haptics;
  final String source;
  final bool completed;
  final String? note;
}
