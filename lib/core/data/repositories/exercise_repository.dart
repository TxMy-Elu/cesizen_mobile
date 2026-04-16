import 'package:cesizen_mobile/core/models/exercer_dto.dart';
import 'package:cesizen_mobile/core/models/exercice_dto.dart';
import 'package:cesizen_mobile/core/network/api_client.dart';

class ExerciseRepository {
  ExerciseRepository(this._client);

  final ApiClient _client;

  Future<List<ExerciceDto>> fetchExercises() async {
    final response = await _client.getJson('/api/exercice/list');
    return _asList(response).map(ExerciceDto.fromJson).toList();
  }

  Future<List<ExercerDto>> fetchUserSessions({
    required int userId,
    required String token,
  }) async {
    final response = await _client.getJson(
      '/api/exercer/user/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return _asList(response).map(ExercerDto.fromJson).toList();
  }

  Future<void> recordSession({
    required int userId,
    required int exerciceId,
    required String token,
    DateTime? completedAt,
  }) async {
    await _client.postJson(
      '/api/exercer',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'userId': userId,
        'exerciceId': exerciceId,
        if (completedAt != null) 'completedAt': completedAt.toUtc().toIso8601String(),
      },
    );
  }

  List<Map<String, dynamic>> _asList(dynamic response) {
    if (response is! List) {
      return const [];
    }
    return response
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }
}