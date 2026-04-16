class UserPreferences {
  const UserPreferences({
    required this.defaultDurationMin,
    required this.rhythm,
    required this.haptics,
    required this.zenTheme,
  });

  final int defaultDurationMin;
  final String rhythm;
  final bool haptics;
  final bool zenTheme;
}

class FakeUser {
  const FakeUser({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.rgpdConsent,
    required this.accountStatus,
    this.preferences,
  });

  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String createdAt;
  final bool rgpdConsent;
  final String accountStatus;
  final UserPreferences? preferences;

  String get fullName => '$firstName $lastName';
}
