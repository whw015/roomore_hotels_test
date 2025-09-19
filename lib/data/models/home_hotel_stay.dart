import 'package:cloud_firestore/cloud_firestore.dart';

class HomeHotelStay {
  const HomeHotelStay({
    required this.hotelId,
    required this.hotelCode,
    required this.hotelName,
    required this.roomNumber,
    required this.isActive,
    this.hotelNameAr,
    this.hotelNameEn,
    this.status,
    this.updatedAt,
  });

  final String hotelId;
  final String hotelCode;
  final String hotelName;
  final String roomNumber;
  final bool isActive;
  final String? hotelNameAr;
  final String? hotelNameEn;
  final String? status;
  final DateTime? updatedAt;

  HomeHotelStay copyWith({
    String? hotelId,
    String? hotelCode,
    String? hotelName,
    String? roomNumber,
    bool? isActive,
    String? hotelNameAr,
    String? hotelNameEn,
    String? status,
    DateTime? updatedAt,
  }) {
    return HomeHotelStay(
      hotelId: hotelId ?? this.hotelId,
      hotelCode: hotelCode ?? this.hotelCode,
      hotelName: hotelName ?? this.hotelName,
      roomNumber: roomNumber ?? this.roomNumber,
      isActive: isActive ?? this.isActive,
      hotelNameAr: hotelNameAr ?? this.hotelNameAr,
      hotelNameEn: hotelNameEn ?? this.hotelNameEn,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HomeHotelStay.fromFirestore(String id, Map<String, dynamic> data) {
    String? asString(dynamic value) {
      if (value == null) {
        return null;
      }
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    final code = asString(data['hotelCode'] ?? data['code']) ?? id;
    final nameAr = asString(data['hotelNameAr'] ?? data['nameAr']);
    final nameEn = asString(data['hotelNameEn'] ?? data['nameEn']);
    final baseName =
        asString(data['hotelName'] ?? data['name']) ?? nameEn ?? nameAr ?? code;
    final room = asString(data['roomNumber'] ?? data['room']) ?? '';
    final rawStatus = asString(data['status']) ?? '';
    final isActive = data['isActive'] is bool
        ? data['isActive'] as bool
        : rawStatus.toLowerCase() == 'active';
    DateTime? updated;
    final updatedRaw = data['updatedAt'];
    if (updatedRaw is Timestamp) {
      updated = updatedRaw.toDate();
    } else if (updatedRaw is DateTime) {
      updated = updatedRaw;
    }

    return HomeHotelStay(
      hotelId: asString(data['hotelId']) ?? id,
      hotelCode: code,
      hotelName: baseName,
      roomNumber: room,
      isActive: isActive,
      hotelNameAr: nameAr,
      hotelNameEn: nameEn,
      status: rawStatus.isEmpty ? null : rawStatus,
      updatedAt: updated,
    );
  }
}
