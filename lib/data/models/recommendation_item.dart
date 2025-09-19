class RecommendationItem {
  const RecommendationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;

  factory RecommendationItem.fromMap(String id, Map<String, dynamic> data) {
    return RecommendationItem(
      id: id,
      title: (data['title'] as String?)?.trim() ?? id,
      description: (data['description'] as String?)?.trim() ?? '',
      iconName: (data['icon'] as String?)?.trim() ?? 'local_offer',
    );
  }
}
