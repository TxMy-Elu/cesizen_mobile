import 'package:cesizen_mobile/core/models/article_dto.dart';
import 'package:cesizen_mobile/core/models/categorie_dto.dart';
import 'package:cesizen_mobile/core/network/api_client.dart';

class ArticleRepository {
  ArticleRepository(this._client);

  final ApiClient _client;

  Future<List<ArticleDto>> fetchPublicArticles() async {
    final response = await _client.getJson('/api/article/public');
    return _asList(response).map(ArticleDto.fromJson).toList();
  }

  Future<ArticleDto> fetchArticle(int id) async {
    final response = await _client.getJson('/api/article/$id');
    return ArticleDto.fromJson((response as Map).cast<String, dynamic>());
  }

  Future<List<CategorieDto>> fetchCategories() async {
    final response = await _client.getJson('/api/categorie/list');
    return _asList(response).map(CategorieDto.fromJson).toList();
  }

  Future<void> recordConsultation({
    required int userId,
    required int articleId,
    required String token,
  }) async {
    await _client.postJson(
      '/api/consulter',
      headers: {'Authorization': 'Bearer $token'},
      body: {'idUtilisateur': userId, 'idArticle': articleId},
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