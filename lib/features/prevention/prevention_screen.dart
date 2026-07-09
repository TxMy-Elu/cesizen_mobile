import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/data/repositories/article_repository.dart';
import 'package:cesizen_mobile/core/models/article_dto.dart';
import 'package:cesizen_mobile/core/models/categorie_dto.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';
import 'package:cesizen_mobile/core/models/user_session.dart';
import 'package:cesizen_mobile/features/prevention/article_detail_page.dart';

class PreventionScreen extends StatefulWidget {
  const PreventionScreen({
    super.key,
    required this.session,
    required this.articleRepository,
  });

  final UserSession session;
  final ArticleRepository articleRepository;

  @override
  State<PreventionScreen> createState() => _PreventionScreenState();
}

class _PreventionScreenState extends State<PreventionScreen> {
  String _filter = 'Tous';
  bool _isLoading = true;
  String? _errorMessage;
  List<ArticleDto> _articles = [];
  List<CategorieDto> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await widget.articleRepository.fetchPublicArticles();
      final categories = await widget.articleRepository.fetchCategories();
      if (!mounted) {
        return;
      }
      setState(() {
        _articles = articles;
        _categories = categories;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Tous',
      ..._categories.map((category) => category.libelle),
    ];
    final visible = _articles
        .where((article) => _filter == 'Tous' || article.categorieLibelle == _filter)
        .toList();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        const Text(
          'Catalogue prévention',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories
              .map(
                (category) => ChoiceChip(
                  label: Text(category),
                  selected: _filter == category,
                  onSelected: (_) => setState(() => _filter = category),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Text(
          'Articles publiés: ${_articles.where((item) => item.estPublie).length}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...visible.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                title: Text(article.titre),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_excerpt(article.contenu)}\nType: ${article.typeMedia}',
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () async {
                  await _registerViewIfPossible(article);
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailPage(article: article),
                    ),
                  );
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _registerViewIfPossible(ArticleDto article) async {
    final userId = widget.session.userIdNumber;
    final token = widget.session.authToken;
    if (userId == null || token == null || token.isEmpty) {
      return;
    }

    try {
      await widget.articleRepository.recordConsultation(
        userId: userId,
        articleId: article.idArticle,
        token: token,
      );
      widget.session.registerArticleView();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  String _excerpt(String content) {
    final normalized = content.replaceAll('\n', ' ').trim();
    if (normalized.length <= 90) {
      return normalized;
    }
    return '${normalized.substring(0, 87)}...';
  }
}
