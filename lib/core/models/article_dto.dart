class ArticleDto {
  const ArticleDto({
    required this.idArticle,
    required this.titre,
    required this.contenu,
    required this.typeMedia,
    required this.estPublie,
    this.mediaUrl,
    this.datePublication,
    this.dateModification,
    this.idCategorie,
    this.categorieLibelle,
  });

  final int idArticle;
  final String titre;
  final String contenu;
  final String typeMedia;
  final String? mediaUrl;
  final DateTime? datePublication;
  final DateTime? dateModification;
  final bool estPublie;
  final int? idCategorie;
  final String? categorieLibelle;

  factory ArticleDto.fromJson(Map<String, dynamic> json) {
    return ArticleDto(
      idArticle: _asInt(json['idArticle']) ?? 0,
      titre: json['titre']?.toString() ?? '',
      contenu: json['contenu']?.toString() ?? '',
      typeMedia: json['typeMedia']?.toString() ?? 'text',
      mediaUrl: json['mediaUrl']?.toString(),
      datePublication: _asDateTime(json['datePublication']),
      dateModification: _asDateTime(json['dateModification']),
      estPublie: json['estPublie'] == true,
      idCategorie: _asInt(json['idCategorie']),
      categorieLibelle: json['categorieLibelle']?.toString(),
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