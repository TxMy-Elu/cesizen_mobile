class ConsulterDto {
  const ConsulterDto({
    required this.idConsulter,
    required this.idUtilisateur,
    required this.idArticle,
    required this.viewedAt,
    this.nomUtilisateur,
    this.titreArticle,
  });

  final int idConsulter;
  final int idUtilisateur;
  final String? nomUtilisateur;
  final int idArticle;
  final String? titreArticle;
  final DateTime? viewedAt;

  factory ConsulterDto.fromJson(Map<String, dynamic> json) {
    return ConsulterDto(
      idConsulter: _asInt(json['idConsulter']) ?? 0,
      idUtilisateur: _asInt(json['idUtilisateur']) ?? 0,
      nomUtilisateur: json['nomUtilisateur']?.toString(),
      idArticle: _asInt(json['idArticle']) ?? 0,
      titreArticle: json['titreArticle']?.toString(),
      viewedAt: _asDateTime(json['viewedAt']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _asDateTime(Object? value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text)?.toUtc();
  }
}