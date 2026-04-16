class BreathingPreset {
  const BreathingPreset({
    required this.name,
    required this.pattern,
    required this.defaultDurationMin,
    required this.hapticsRecommended,
  });

  final String name;
  final String pattern;
  final int defaultDurationMin;
  final bool hapticsRecommended;
}
