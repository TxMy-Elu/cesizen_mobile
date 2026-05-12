import 'package:flutter/material.dart';

import 'package:cesizen_mobile/core/models/article_dto.dart';
import 'package:cesizen_mobile/core/services/media_service.dart';
import 'package:cesizen_mobile/core/theme/app_theme.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({super.key, required this.article});

  final ArticleDto article;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    final url = resolveMediaUrl(widget.article.mediaUrl);
    if (url.isEmpty) return;

    setState(() => _isDownloading = true);
    try {
      await openMedia(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final hasMedia = article.mediaUrl != null && article.mediaUrl!.isNotEmpty;

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
                  if (hasMedia) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isDownloading ? null : _handleDownload,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(
                          _isDownloading
                              ? 'Ouverture...'
                              : 'Voir le document associé',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: CesizenColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Publication',
                    value: article.datePublication?.toLocal().toString().split(' ').first ?? 'N/A',
                  ),
                  if (article.dateModification != null)
                    _InfoRow(
                      label: 'Mise à jour',
                      value: article.dateModification!.toLocal().toString().split(' ').first,
                    ),
                  _InfoRow(
                    label: 'Statut',
                    value: article.estPublie ? 'Publié' : 'Brouillon',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: CesizenColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
