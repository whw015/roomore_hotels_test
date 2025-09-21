import 'package:cloud_firestore/cloud_firestore.dart';

import 'localized_text.dart';

class Item {
  final String id;
  final LocalizedText name;
  final LocalizedText? description;
  final double price;
  final String currency;

  /// معرّف القسم. نقرأ من sectionId وإن لم يوجد نستخدم parentSectionId للتوافق العكسي.
  final String sectionId;
  final bool isAvailable;
  final List<String> imageUrls;

  final List<dynamic>? options;

  Item({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.sectionId,
    required this.isAvailable,
    required this.imageUrls,
    this.options,
  });

  factory Item.fromDoc(String id, Map<String, dynamic> data) {
    // name / description
    final nameMap = (data['name'] is Map)
        ? (data['name'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final descMap = (data['description'] is Map)
        ? (data['description'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final name = LocalizedText(
      ar: nameMap['ar'] as String?,
      en: nameMap['en'] as String?,
    );

    final LocalizedText? desc = descMap.isEmpty
        ? null
        : LocalizedText(
            ar: descMap['ar'] as String?,
            en: descMap['en'] as String?,
          );

    // sectionId موحّد (يدعم fallback على parentSectionId)
    final String secId =
        (data['sectionId'] ?? data['parentSectionId'] ?? '') as String;

    // imageUrls (قائمة نصوص)
    final List<String> imgs = (data['imageUrls'] is List)
        ? (data['imageUrls'] as List).whereType<String>().toList(
            growable: false,
          )
        : const <String>[];

    // options قد تكون List أو Map أو null — نحولها لقائمة مرنة
    List<dynamic>? opts;
    final rawOpts = data['options'];
    if (rawOpts is List) {
      opts = List<dynamic>.from(rawOpts);
    } else if (rawOpts is Map) {
      opts = <dynamic>[rawOpts];
    } else {
      opts = null;
    }

    return Item(
      id: id,
      name: name,
      description: desc,
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: (data['currency'] as String?) ?? '',
      sectionId: secId,
      isAvailable: (data['isAvailable'] as bool?) ?? true,
      imageUrls: imgs,
      options: opts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': {'ar': name.ar, 'en': name.en},
      if (description != null)
        'description': {'ar': description!.ar, 'en': description!.en},
      'price': price,
      'currency': currency,
      'sectionId': sectionId,
      'isAvailable': isAvailable,
      'imageUrls': imageUrls,
      if (options != null) 'options': options,
    };
  }

  factory Item.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    return Item.fromDoc(snap.id, snap.data() ?? const {});
  }
}
