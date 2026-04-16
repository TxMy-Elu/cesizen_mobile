class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.type,
    required this.userId,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  final String token;
  final String type;
  final int userId;
  final String email;
  final String nom;
  final String prenom;
  final String role;

  String get fullName => '$prenom $nom'.trim();

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Bearer',
      userId: _asInt(json['userId']) ?? 0,
      email: json['email']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      role: json['role']?.toString() ?? 'ROLE_USER',
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