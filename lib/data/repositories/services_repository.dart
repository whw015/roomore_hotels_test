import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../data/models/section.dart';
import '../../data/models/item.dart';
import '../../data/models/localized_text.dart';
import '../../config/env.dart';

/// يقرأ من:
/// hotels/{hotelId}/service_sections  (isActive, isRoot, parentSectionId, name{ar,en}, order)
/// hotels/{hotelId}/service_items     (sectionId, isAvailable, …)
class ServicesRepository {
  final FirebaseFirestore _db;
  ServicesRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  bool get _useHttp => Env.useHttpServices;
  String get _baseUrl => Env.apiBaseUrl;

  Map<String, String> _hotelQuery(String hotelIdOrCode) {
    final id = hotelIdOrCode.trim();
    final isDigits = RegExp(r'^\\d+$').hasMatch(id);
    return isDigits ? {'hotel_id': id} : {'code': id};
  }

  CollectionReference<Map<String, dynamic>> _sections(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_sections');

  CollectionReference<Map<String, dynamic>> _items(String hotelId) =>
      _db.collection('hotels').doc(hotelId).collection('service_items');

  // ---------- Sections ----------

  /// الأقسام الجذرية الفعّالة (isRoot && isActive). تركت بدون orderBy لتجنّب الحاجة لفهرس مركّب.
  Stream<List<Section>> streamRootSectionsActive(String hotelId) {
    if (_useHttp) {
      return _httpFetchSections(hotelId).asStream().map((all) =>
          all.where((s) => (s.parentSectionId == null || s.parentSectionId!.isEmpty) && s.isActive).toList());
    }
    return _sections(hotelId)
        .where('isRoot', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList());
  }

  /// الأقسام الفرعية الفعّالة تحت قسم معيّن
  Stream<List<Section>> streamActiveSubSections(
    String hotelId,
    String parentSectionId,
  ) {
    if (_useHttp) {
      return _httpFetchSections(hotelId).asStream().map((all) => all
          .where((s) => (s.parentSectionId ?? '') == parentSectionId && s.isActive)
          .toList());
    }
    return _sections(hotelId)
        .where('parentSectionId', isEqualTo: parentSectionId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Section.fromDoc(d.id, d.data())).toList());
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
    if (_useHttp) {
      return _httpFetchItemsBySection(hotelId, sectionId, onlyAvailable).asStream();
    }
    Query<Map<String, dynamic>> q =
        _items(hotelId).where('sectionId', isEqualTo: sectionId);
    if (onlyAvailable) q = q.where('isAvailable', isEqualTo: true);
    return q.snapshots()
        .map((s) => s.docs.map((d) => Item.fromDoc(d.id, d.data())).toList());
  }

  /// جميع العناصر المتاحة على مستوى الفندق — لا تستخدم أي where على sectionId
  Stream<List<Item>> streamAllAvailableItems(String hotelId) {
    if (_useHttp) {
      // Not required by current UI; return empty once
      return Stream<List<Item>>.value(const <Item>[]);
    }
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

  // ---------- HTTP helpers ----------
  Future<List<Section>> _httpFetchSections(String hotelId) async {
    final uri = Uri.parse('$_baseUrl/services/sections_flat.php')
        .replace(queryParameters: _hotelQuery(hotelId));
    final resp = await http.get(uri);
    if (resp.statusCode != 200) { throw Exception("HTTP ${resp.statusCode} while loading sections"); }
    final data = json.decode(resp.body);
    final list = (data is Map && data['sections'] is List)
        ? data['sections'] as List
        : (data is List)
            ? data
            : <dynamic>[];
    int idx = 0;
    return list.whereType<Map>().map((raw) {
      final m = raw.cast<String, dynamic>();
      final nameMap = (m['name'] is Map)
          ? (m['name'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      return Section(
        id: (m['id'] ?? '').toString(),
        name: LocalizedText(
          ar: (nameMap['ar'] ?? m['title_ar'])?.toString(),
          en: (nameMap['en'] ?? m['title_en'])?.toString(),
        ),
        parentSectionId: (m['parentSectionId'] ?? m['parent_section_id'])
            ?.toString(),
        order: (m['order'] is int)
            ? m['order'] as int
            : (m['order'] is num)
                ? (m['order'] as num).toInt()
                : idx++,
        isActive: (m['isActive'] is bool)
            ? m['isActive'] as bool
            : (m['is_active'] is int)
                ? (m['is_active'] as int) == 1
                : true,
        iconUrl: m['iconUrl']?.toString() ?? m['icon_url']?.toString(),
        imageUrl: m['imageUrl']?.toString() ?? m['image_url']?.toString(),
        type: m['type']?.toString(),
      );
    }).toList();
  }

  Future<List<Item>> _httpFetchItemsBySection(
    String hotelId,
    String sectionId,
    bool onlyAvailable,
  ) async {
    final params = _hotelQuery(hotelId);
    params['sectionId'] = sectionId;
    final uri = Uri.parse('$_baseUrl/services/items_by_section.php')
        .replace(queryParameters: params);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) { throw Exception("HTTP ${resp.statusCode} while loading items"); }
    final data = json.decode(resp.body);
    final list = (data is Map && data['items'] is List)
        ? data['items'] as List
        : (data is List)
            ? data
            : <dynamic>[];
    final items = list.whereType<Map>().map((m0) {
      final m = m0.cast<String, dynamic>();
      return Item.fromDoc((m['id'] ?? '').toString(), m);
    }).toList();
    if (onlyAvailable) {
      return items.where((e) => e.isAvailable).toList();
    }
    return items;
  }
}
