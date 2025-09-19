class QuickActionItem {
  const QuickActionItem({
    required this.id,
    required this.label,
    required this.iconName,
    this.route,
  });

  final String id;
  final String label;
  final String iconName;
  final String? route;

  factory QuickActionItem.fromMap(String id, Map<String, dynamic> data) {
    return QuickActionItem(
      id: id,
      label: (data['label'] as String?)?.trim() ?? id,
      iconName: (data['icon'] as String?)?.trim() ?? 'task_alt',
      route: (data['route'] as String?)?.trim(),
    );
  }
}
