class CategorieDto {
  const CategorieDto({
    required this.idCategorie,
    required this.libelle,
    this.description,
  });

  final int idCategorie;
  final String libelle;
  final String? description;

  factory CategorieDto.fromJson(Map<String, dynamic> json) {
    return CategorieDto(
      idCategorie: _asInt(json['idCategorie']) ?? 0,
      libelle: json['libelle']?.toString() ?? '',
      description: json['description']?.toString(),
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
}