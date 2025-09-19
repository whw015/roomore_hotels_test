class FavoriteItem {
  const FavoriteItem({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final double rating;
  final String? imageUrl;

  factory FavoriteItem.fromMap(String id, Map<String, dynamic> data) {
    return FavoriteItem(
      id: id,
      title: (data['title'] as String?)?.trim() ?? id,
      category: (data['category'] as String?)?.trim() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      imageUrl: (data['imageUrl'] as String?)?.trim(),
    );
  }
}
