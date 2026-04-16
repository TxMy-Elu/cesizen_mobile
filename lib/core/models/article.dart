class Article {
  const Article({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.markdownContent,
    required this.category,
    required this.status,
    required this.isValidatedByHealthPro,
    required this.updatedAt,
  });

  final String id;
  final String slug;
  final String title;
  final String summary;
  final String markdownContent;
  final String category;
  final String status;
  final bool isValidatedByHealthPro;
  final String updatedAt;

  bool get isPublished => status == 'PUBLIE';
}
