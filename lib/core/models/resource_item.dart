class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.type,
    required this.fileName,
    required this.sizeKb,
    required this.category,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String type;
  final String fileName;
  final int sizeKb;
  final String category;
  final String status;
  final String updatedAt;
}
