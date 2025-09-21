import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/section.dart';
import '../../data/models/item.dart';

/// يقرأ من:
/// hotels/{hotelId}/service_sections  (isActive, isRoot, parentSectionId, name{ar,en}, order)
/// hotels/{hotelId}/service_items     (sectionId, isAvailable, …)
class ServicesRepository {
  final FirebaseFirestore _db;
  ServicesRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _sections(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_sections');

  CollectionReference<Map<String, dynamic>> _items(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_items');

  // ---------- Sections ----------

  /// الأقسام الجذرية الفعّالة (isRoot && isActive). تركت بدون orderBy لتجنّب الحاجة لفهرس مركّب.
  Stream<List<Section>> streamRootSectionsActive(String hotelId) {
    return _sections(hotelId)
        .where('isRoot', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
        );
  }

  /// الأقسام الفرعية الفعّالة تحت قسم معيّن
  Stream<List<Section>> streamActiveSubSections(
    String hotelId,
    String parentSectionId,
  ) {
    return _sections(hotelId)
        .where('parentSectionId', isEqualTo: parentSectionId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
        );
  }

  /// جميع الأقسام الفرعية الفعّالة (مفيدة للتجميع أو الفلترة عند العرض)
  Stream<List<Section>> streamAllActiveSubSections(String hotelId) {
    return _sections(hotelId)
        .where('isRoot', isEqualTo: false)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
        );
  }

  // ---------- Items ----------

  /// عناصر قسم معيّن (المتاحة فقط افتراضياً)
  Stream<List<Item>> streamAvailableItems(
    String hotelId,
    String sectionId, {
    bool onlyAvailable = true,
  }) {
    Query<Map<String, dynamic>> q = _items(
      hotelId,
    ).where('sectionId', isEqualTo: sectionId);
    if (onlyAvailable) q = q.where('isAvailable', isEqualTo: true);
    return q.snapshots().map(
      (s) => s.docs.map((d) => Item.fromDoc(d.id, d.data())).toList(),
    );
  }

  /// جميع العناصر المتاحة على مستوى الفندق — لا تستخدم أي where على sectionId
  Stream<List<Item>> streamAllAvailableItems(String hotelId) {
    return _items(hotelId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Item.fromDoc(d.id, d.data())).toList());
  }

  /// مجموعة sectionIds التي لديها عناصر متاحة (تُفيد في إخفاء الأقسام التي لا تحتوي عناصر)
  Stream<Set<String>> streamSectionIdsHavingItems(String hotelId) {
    return streamAllAvailableItems(hotelId).map((items) {
      final ids = <String>{};
      for (final it in items) {
        if (it.sectionId.isNotEmpty) ids.add(it.sectionId);
      }
      return ids;
    });
  }
}
