class ExerciceDto {
  const ExerciceDto({
    required this.idExercice,
    required this.nom,
    required this.dureeInspiration,
    required this.dureeApnee,
    required this.dureeExpiration,
    required this.dureeSession,
    this.description,
  });

  final int idExercice;
  final String nom;
  final int dureeInspiration;
  final int dureeApnee;
  final int dureeExpiration;
  final int dureeSession;
  final String? description;

  factory ExerciceDto.fromJson(Map<String, dynamic> json) {
    return ExerciceDto(
      idExercice: _asInt(json['idExercice']) ?? 0,
      nom: json['nom']?.toString() ?? '',
      dureeInspiration: _asInt(json['dureeInspiration']) ?? 0,
      dureeApnee: _asInt(json['dureeApnee']) ?? 0,
      dureeExpiration: _asInt(json['dureeExpiration']) ?? 0,
      dureeSession: _asInt(json['dureeSession']) ?? 120,
      description: json['description']?.toString(),
    );
  }

  String get rhythmLabel =>
      '$dureeInspiration s / $dureeApnee s / $dureeExpiration s';

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}