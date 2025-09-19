import 'package:cloud_firestore/cloud_firestore.dart';
import 'localized_text.dart';

class Item {
  final String id;
  final LocalizedText name;
  final LocalizedText? description;
  final List<String> imageUrls;
  final double price;
  final String currency;
  final bool isAvailable;
  final List<Map<String, dynamic>> options; // إن لم تستعملها اتركها []

  const Item({
    required this.id,
    required this.name,
    this.description,
    required this.imageUrls,
    required this.price,
    required this.currency,
    required this.isAvailable,
    required this.options,
  });

  factory Item.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Item(
      id: doc.id,
      name: LocalizedText.fromJson(data['name']),
      description: data['description'] != null
          ? LocalizedText.fromJson(data['description'])
          : null,
      imageUrls:
          (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : double.tryParse('${data['price']}') ?? 0.0,
      currency: (data['currency'] ?? 'SAR').toString(),
      isAvailable: (data['isAvailable'] as bool?) ?? true,
      options:
          (data['options'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          const [],
    );
  }

  factory Item.fromMap(Map<String, dynamic> data, {String id = ''}) {
    return Item(
      id: id,
      name: LocalizedText.fromJson(data['name']),
      description: data['description'] != null
          ? LocalizedText.fromJson(data['description'])
          : null,
      imageUrls:
          (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : double.tryParse('${data['price']}') ?? 0.0,
      currency: (data['currency'] ?? 'SAR').toString(),
      isAvailable: (data['isAvailable'] as bool?) ?? true,
      options:
          (data['options'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.toJson(), // ✅ ليس toMap
      'description': description?.toJson(),
      'imageUrls': imageUrls,
      'price': price,
      'currency': currency,
      'isAvailable': isAvailable,
      'options': options,
    };
  }

  Item copyWith({
    String? id,
    LocalizedText? name,
    LocalizedText? description,
    List<String>? imageUrls,
    double? price,
    String? currency,
    bool? isAvailable,
    List<Map<String, dynamic>>? options,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isAvailable: isAvailable ?? this.isAvailable,
      options: options ?? this.options,
    );
  }
}
