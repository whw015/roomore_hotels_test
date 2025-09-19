import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/section.dart';
import '../models/item.dart';
import '../models/localized_text.dart'; // ✅ مهم

class AdminServicesRepository {
  final FirebaseFirestore _db;
  AdminServicesRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _hotelSections(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_sections');

  CollectionReference<Map<String, dynamic>> _hotelItems(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_items');

  Future<void> addRootSection({
    required String hotelId,
    required String nameAr,
    required String nameEn,
    required int order,
    required bool isActive,
  }) async {
    final data = {
      'name': LocalizedText(ar: nameAr, en: nameEn).toJson(),
      'parentSectionId': null,
      'isActive': isActive,
      'order': order,
      'isRoot': true,
    };
    await _hotelSections(hotelId).add(data);
  }

  Future<void> addSubSection({
    required String hotelId,
    required String parentSectionId,
    required String nameAr,
    required String nameEn,
    required int order,
    required bool isActive,
  }) async {
    final data = {
      'name': LocalizedText(ar: nameAr, en: nameEn).toJson(),
      'parentSectionId': parentSectionId,
      'isActive': isActive,
      'order': order,
      'isRoot': false,
    };
    await _hotelSections(hotelId).add(data);
  }

  Stream<List<Section>> streamRootServiceSectionsFlexible(String hotelId) {
    final col = _hotelSections(hotelId);

    Stream<List<Section>> asStream(Query<Map<String, dynamic>> q) => q
        .snapshots()
        .map((s) => s.docs.map((d) => Section.fromDoc(d)).toList());

    final q1 = col.where('isRoot', isEqualTo: true).orderBy('order');
    final q2 = col.where('parentSectionId', isNull: true).orderBy('order');
    final q3 = col.where('parentSectionId', isEqualTo: '').orderBy('order');
    final q4 = col.where('parentSectionId', isEqualTo: 'root').orderBy('order');

    return Stream<List<Section>>.multi((controller) {
      final s1 = asStream(q1).listen(controller.add);
      final s2 = asStream(q2).listen(controller.add);
      final s3 = asStream(q3).listen(controller.add);
      final s4 = asStream(q4).listen(controller.add);
      controller.onCancel = () {
        s1.cancel();
        s2.cancel();
        s3.cancel();
        s4.cancel();
      };
    });
  }

  Stream<List<Section>> streamSubSections(String hotelId, String parentId) {
    return _hotelSections(hotelId)
        .where('parentSectionId', isEqualTo: parentId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => Section.fromDoc(d)).toList());
  }

  Stream<List<Item>> streamItems(String hotelId, String sectionId) {
    return _hotelItems(hotelId)
        .where('sectionId', isEqualTo: sectionId)
        .orderBy('order', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Item.fromDoc(d)).toList());
  }

  Future<void> addItem({
    required String hotelId,
    required String sectionId,
    required Item item,
    String? parentSectionId,
  }) async {
    final data = item.toJson();
    data['sectionId'] = sectionId;
    if (parentSectionId != null) data['parentSectionId'] = parentSectionId;
    await _hotelItems(hotelId).add(data);
  }
}
