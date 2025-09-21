// lib/data/models/section.dart
import 'localized_text.dart';

class Section {
  final String id;
  final LocalizedText name;
  final String? parentSectionId; // null = root
  final int order;
  final bool isActive;
  final String? iconUrl;
  final String? imageUrl;
  final String? type; // "menu", "service", ...

  Section({
    required this.id,
    required this.name,
    this.parentSectionId,
    this.order = 0,
    this.isActive = true,
    this.iconUrl,
    this.imageUrl,
    this.type,
  });

  factory Section.fromDoc(String id, Map<String, dynamic> data) {
    return Section(
      id: id,
      name: LocalizedText.fromMap(data['name'] as Map<String, dynamic>?),
      parentSectionId: data['parent_section_id'] as String?,
      order: (data['order'] ?? 0) as int,
      isActive: (data['is_active'] ?? true) as bool,
      iconUrl: data['icon_url'] as String?,
      imageUrl: data['image_url'] as String?,
      type: data['type'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name.toMap(),
    'parent_section_id': parentSectionId,
    'order': order,
    'is_active': isActive,
    if (iconUrl != null) 'icon_url': iconUrl,
    if (imageUrl != null) 'image_url': imageUrl,
    if (type != null) 'type': type,
  };
}
