class ArticleViewRecord {
  const ArticleViewRecord({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.viewedAt,
  });

  final String id;
  final String userId;
  final String articleId;
  final String viewedAt;
}
