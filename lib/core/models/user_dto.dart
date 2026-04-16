class UserDto {
  const UserDto({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.active,
    required this.creationDate,
    required this.roleId,
    required this.roleLibelle,
  });

  final int id;
  final String nom;
  final String prenom;
  final String email;
  final bool active;
  final DateTime? creationDate;
  final int? roleId;
  final String roleLibelle;

  String get fullName => '$prenom $nom'.trim();

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: _asInt(json['id']) ?? 0,
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      active: json['active'] == true,
      creationDate: _asDateTime(json['creationDate']),
      roleId: _asInt(json['roleId']),
      roleLibelle: json['roleLibelle']?.toString() ?? 'ROLE_USER',
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