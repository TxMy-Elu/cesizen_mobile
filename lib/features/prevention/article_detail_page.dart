import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/models/article_dto.dart';
import 'package:cesizen_mobile/core/theme/app_theme.dart';

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.article});

  final ArticleDto article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.categorieLibelle ?? 'Prévention',
                    style: const TextStyle(
                      color: CesizenColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.titre,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: CesizenColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(article.contenu, style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 12),
                  Text('Type média: ${article.typeMedia}'),
                  Text('Media: ${article.mediaUrl ?? 'Aucun'}'),
                  Text('Publication: ${article.datePublication?.toIso8601String() ?? 'N/A'}'),
                  Text('Maj: ${article.dateModification?.toIso8601String() ?? 'N/A'}'),
                  Text('Publié: ${article.estPublie ? 'Oui' : 'Non'}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
