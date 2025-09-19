// lib/data/models/section.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'localized_text.dart';

class Section {
  final String id;
  final LocalizedText name;
  final String? parentSectionId; // null للجذري
  final bool isActive;
  final int order;
  final bool isRoot;

  Section({
    required this.id,
    required this.name,
    required this.parentSectionId,
    required this.isActive,
    required this.order,
    required this.isRoot,
  });

  factory Section.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final dynamic rawName = data['name'];
    final name = LocalizedText.fromJson(rawName); // ✅ يتحمل String/Map

    final parentId = (data.containsKey('parentSectionId'))
        ? data['parentSectionId'] as String?
        : (data['parentId'] as String?); // دعم اسم قديم

    final bool isRoot =
        (data['isRoot'] as bool?) ?? (parentId == null || parentId.isEmpty);

    return Section(
      id: doc.id,
      name: name,
      parentSectionId: parentId,
      isActive: (data['isActive'] as bool?) ?? true,
      order: (data['order'] is int)
          ? data['order'] as int
          : int.tryParse('${data['order']}') ?? 0,
      isRoot: isRoot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(), // ✅ Map للّغات
      'parentSectionId': parentSectionId,
      'isActive': isActive,
      'order': order,
      'isRoot': isRoot,
    };
  }
}
