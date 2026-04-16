import 'package:cesizen_mobile/core/models/auth_response.dart';
import 'package:cesizen_mobile/core/models/fake_user.dart';

class UserSession {
  bool isAuthenticated = false;
  String userId = 'anonymous';
  int? userIdNumber;
  String role = 'VISITEUR';
  String userName = 'Visiteur';
  String email = 'anonyme@local';
  String createdAt = '';
  bool rgpdConsent = false;
  String? authToken;
  String authType = 'Bearer';
  UserPreferences? preferences;
  int breathingSessions = 0;
  int articleViews = 0;

  String? get authorizationHeader =>
      authToken == null || authToken!.isEmpty ? null : '$authType $authToken';

  void login({required String name, required String email}) {
    isAuthenticated = true;
    userId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    userIdNumber = null;
    role = 'UTILISATEUR';
    userName = name;
    this.email = email;
    createdAt = DateTime.now().toUtc().toIso8601String();
    rgpdConsent = true;
    authToken = null;
    authType = 'Bearer';
  }

  void loginWithFakeUser(FakeUser user) {
    isAuthenticated = true;
    userId = user.id;
    userIdNumber = null;
    role = user.role;
    userName = user.fullName;
    email = user.email;
    createdAt = user.createdAt;
    rgpdConsent = user.rgpdConsent;
    preferences = user.preferences;
    authToken = null;
    authType = 'Bearer';
  }

  void loginWithAuthResponse(AuthResponse response) {
    isAuthenticated = true;
    userIdNumber = response.userId;
    userId = response.userId.toString();
    role = response.role;
    userName = response.fullName;
    email = response.email;
    createdAt = DateTime.now().toUtc().toIso8601String();
    rgpdConsent = true;
    preferences = null;
    authToken = response.token;
    authType = response.type.isEmpty ? 'Bearer' : response.type;
  }

  void logout() {
    isAuthenticated = false;
    userId = 'anonymous';
    userIdNumber = null;
    role = 'VISITEUR';
    userName = 'Visiteur';
    email = 'anonyme@local';
    createdAt = '';
    rgpdConsent = false;
    preferences = null;
    authToken = null;
    authType = 'Bearer';
    breathingSessions = 0;
    articleViews = 0;
  }

  void registerBreathingSession() {
    if (isAuthenticated) {
      breathingSessions++;
    }
  }

  void registerArticleView() {
    if (isAuthenticated) {
      articleViews++;
    }
  }
}
