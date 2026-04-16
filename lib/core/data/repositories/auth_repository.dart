import 'package:cesizen_mobile/core/models/auth_response.dart';
import 'package:cesizen_mobile/core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthResponse> login({required String email, required String password}) async {
    final response = await _client.postJson(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson((response as Map).cast<String, dynamic>());
  }

  Future<AuthResponse> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
  }) async {
    final response = await _client.postJson(
      '/api/auth/register',
      body: {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson((response as Map).cast<String, dynamic>());
  }

  Future<void> forgotPassword(String email) async {
    await _client.postJson(
      '/api/auth/forgot-password',
      body: {'email': email},
    );
  }

  Future<bool> validateResetToken(String token) async {
    final response = await _client.getJson(
      '/api/auth/reset-password/validate',
      queryParameters: {'token': token},
    );
    final json = (response as Map).cast<String, dynamic>();
    return json['valid'] == true;
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _client.postJson(
      '/api/auth/reset-password',
      body: {'token': token, 'newPassword': newPassword},
    );
  }
}