import 'package:cesizen_mobile/core/models/consulter_dto.dart';
import 'package:cesizen_mobile/core/network/api_client.dart';

class ConsultationRepository {
  ConsultationRepository(this._client);

  final ApiClient _client;

  Future<List<ConsulterDto>> fetchUserConsultations({
    required int userId,
    required String token,
  }) async {
    final response = await _client.getJson(
      '/api/consulter/user/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return _asList(response).map(ConsulterDto.fromJson).toList();
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