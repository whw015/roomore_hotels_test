// lib/data/repositories/firestore_repository.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/section.dart';
import '../models/item.dart';

class FirestoreRepository {
  FirestoreRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ---------------- Hotels / Paths ----------------

  CollectionReference<Map<String, dynamic>> _sectionsCol(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('sections');

  CollectionReference<Map<String, dynamic>> _itemsCol(
    String hotelId,
    String sectionId,
  ) => _db
      .collection('hotels')
      .doc(hotelId)
      .collection('sections')
      .doc(sectionId)
      .collection('items');

  /// لو كنت تحتاجها في مكان آخر (اختياري)
  Future<String?> resolveHotelIdByCode(String code) async {
    final qs = await _db
        .collection('hotels')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return null;
    return qs.docs.first.id;
  }

  // ---------------- Sections ----------------

  /// الأقسام الجذرية المفعّلة: parent_section_id == null && is_active == true
  Stream<List<Section>> streamRootSectionsActive(String hotelId) {
    final q = _sectionsCol(hotelId)
        .where('is_active', isEqualTo: true)
        .where('parent_section_id', isNull: true)
        .orderBy('order');
    return q.snapshots().map(
      (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
    );
  }

  /// الأقسام الفرعية المفعّلة لقسم محدد
  Stream<List<Section>> streamActiveSubSections(
    String hotelId,
    String parentSectionId,
  ) {
    final q = _sectionsCol(hotelId)
        .where('parent_section_id', isEqualTo: parentSectionId)
        .where('is_active', isEqualTo: true)
        .orderBy('order');
    return q.snapshots().map(
      (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
    );
  }

  /// جميع الأقسام المفعّلة (نفلتر فرعي/جذري على جهة العميل عند الحاجة)
  Stream<List<Section>> streamAllActiveSections(String hotelId) {
    final q = _sectionsCol(hotelId).where('is_active', isEqualTo: true);
    return q.snapshots().map(
      (s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList(),
    );
  }

  /// جميع الأقسام الفرعية الفعّالة (parent_section_id != null) – فلترة على العميل
  Stream<List<Section>> streamAllActiveSubSections(String hotelId) {
    return streamAllActiveSections(
      hotelId,
    ).map((all) => all.where((s) => s.parentSectionId != null).toList());
  }

  // ---------------- Items (nested) ----------------

  /// عناصر قسم معيّن (المتاحة فقط افتراضيًا)
  Stream<List<Item>> streamItemsInSection(
    String hotelId,
    String sectionId, {
    bool onlyAvailable = true,
  }) {
    Query<Map<String, dynamic>> q = _itemsCol(hotelId, sectionId);
    if (onlyAvailable) {
      q = q.where('is_available', isEqualTo: true);
    }
    return q.snapshots().map(
      (s) => s.docs.map((d) => Item.fromDoc(d.id, d.data())).toList(),
    );
  }

  Stream<bool> streamSectionHasItems(
    String hotelId,
    String sectionId, {
    bool onlyAvailable = true,
  }) {
    Query<Map<String, dynamic>> q = _itemsCol(hotelId, sectionId);
    if (onlyAvailable) {
      q = q.where('is_available', isEqualTo: true);
    }
    return q.limit(1).snapshots().map((s) => s.docs.isNotEmpty);
  }

  /// مجموعة معرفات الأقسام التي لديها عناصر – يدمج عدة Streams في Stream واحد
  Stream<Set<String>> streamSectionIdsHavingItems(
    String hotelId,
    List<String> sectionIds, {
    bool onlyAvailable = true,
  }) {
    final current = <String>{};
    final controller = StreamController<Set<String>>();
    final subs = <StreamSubscription>[];

    void emit() => controller.add(Set<String>.from(current));

    for (final id in sectionIds.toSet()) {
      final sub =
          streamSectionHasItems(
            hotelId,
            id,
            onlyAvailable: onlyAvailable,
          ).listen((has) {
            if (has) {
              if (current.add(id)) emit();
            } else {
              if (current.remove(id)) emit();
            }
          }, onError: controller.addError);
      subs.add(sub);
    }

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };

    // نطلق قيمة أولية فارغة مباشرة
    emit();
    return controller.stream;
  }

  /// الأقسام الجذرية “المرئية”: لديها عناصر مباشرة أو عبر فروعها
  Stream<List<Section>> streamVisibleRootSections(String hotelId) {
    return streamRootSectionsActive(hotelId).asyncExpand((roots) async* {
      // نأخذ لقطة واحدة من جميع الفروع الفعّالة
      final subsOnce = await streamAllActiveSubSections(hotelId).first;

      // سنفحص العناصر في الجذور + فروعها
      final toCheck = <String>{
        ...roots.map((r) => r.id),
        ...subsOnce.map((s) => s.id),
      }.toList(growable: false);

      yield* streamSectionIdsHavingItems(hotelId, toCheck).map((idsWithItems) {
        return roots.where((r) {
          if (idsWithItems.contains(r.id)) return true;
          final children = subsOnce.where((s) => s.parentSectionId == r.id);
          return children.any((s) => idsWithItems.contains(s.id));
        }).toList();
      });
    });
  }
}
