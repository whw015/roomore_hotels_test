import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roomore_hotels_test/config/env.dart';
import 'package:roomore_hotels_test/data/models/guest.dart';

class GuestRepository {
  final String baseUrl = Env.apiBaseUrl;

  Future<List<Guest>> fetchAll({required String hotelId}) async {
    final uri = Uri.parse('$baseUrl/guest/get_guest.php');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load guests (${resp.statusCode})');
    }
    final data = json.decode(resp.body);
    final list = (data is Map && data['guests'] is List)
        ? data['guests'] as List
        : (data is Map && data['employees'] is List)
            ? data['employees'] as List
            : (data is Map && data['data'] is List)
                ? data['data'] as List
                : (data is List)
                    ? data
                    : <dynamic>[];
    return list.whereType<Map>().map((e) => Guest.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Guest> createGuest({
    required String hotelId,
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String nationality,
    DateTime? birthDate,
    String? idNumber,
    String? jobTitle,
    String? employeeId,
  }) async {
    final uri = Uri.parse('$baseUrl/guest/add_guest.php');
    final altUri = Uri.parse('$baseUrl/guests/add_guest.php');
    final payload = {
      'hotel_id': hotelId,
      'name': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'nationality': nationality,
      if (birthDate != null) 'dob': birthDate.toIso8601String(),
      if (idNumber != null) 'id_number': idNumber,
      if (jobTitle != null) 'job_title': jobTitle,
      if (employeeId != null) 'employee_id': employeeId,
    };
    http.Response resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (resp.statusCode != 200) {
      // Try primary with form-encoded (some endpoints expect form)
      final formBody = payload.map((k, v) => MapEntry(k, v.toString()));
      resp = await http.post(uri, body: formBody);
    }
    if (resp.statusCode != 200) {
      // Try alternate path with JSON first, then form
      resp = await http.post(altUri, headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
    }
    if (resp.statusCode != 200) {
      final formBody = payload.map((k, v) => MapEntry(k, v.toString()));
      resp = await http.post(altUri, body: formBody);
    }
    if (resp.statusCode != 200) {
      throw Exception('Failed to create guest (${resp.statusCode})');
    }
    final data = json.decode(resp.body);
    if (data is Map && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    return Guest(
      id: '',
      hotelId: hotelId,
      fullName: fullName,
      email: email,
      phone: phone,
      gender: gender,
      nationality: nationality,
      birthDate: birthDate,
      idNumber: idNumber,
      jobTitle: jobTitle,
      employeeId: employeeId,
    );
  }

  Future<Guest> updateGuest({
    required String id,
    required String hotelId,
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String nationality,
    DateTime? birthDate,
    String? idNumber,
    String? jobTitle,
    String? employeeId,
  }) async {
    final uri = Uri.parse('$baseUrl/guest/update_guest.php');
    final altUri = Uri.parse('$baseUrl/guests/update_guest.php');
    final payload = {
      'id': id,
      'hotel_id': hotelId,
      'name': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'nationality': nationality,
      if (birthDate != null) 'dob': birthDate.toIso8601String(),
      if (idNumber != null) 'id_number': idNumber,
      if (jobTitle != null) 'job_title': jobTitle,
      if (employeeId != null) 'employee_id': employeeId,
    };
    http.Response resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (resp.statusCode != 200) {
      final formBody = payload.map((k, v) => MapEntry(k, v.toString()));
      resp = await http.post(uri, body: formBody);
    }
    if (resp.statusCode != 200) {
      resp = await http.post(altUri, headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
    }
    if (resp.statusCode != 200) {
      final formBody = payload.map((k, v) => MapEntry(k, v.toString()));
      resp = await http.post(altUri, body: formBody);
    }
    if (resp.statusCode != 200) {
      throw Exception('Failed to update guest (${resp.statusCode})');
    }
    final data = json.decode(resp.body);
    if (data is Map && data['error'] != null) {
      throw Exception(data['error'].toString());
    }
    return Guest.fromJson(payload);
  }

  Future<void> deleteGuest({required String id}) async {
    final uri = Uri.parse('$baseUrl/guest/delete_guest.php');
    // Send both json and form-compatible to be safe
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'id': id},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete guest (${resp.statusCode})');
    }
  }

  Future<bool> isGuestActive({required String guestId, required String hotelId}) async {
    final candidates = <Uri>[
      Uri.parse('$baseUrl/guests/is_current.php').replace(queryParameters: {'guest_id': guestId, 'hotel_id': hotelId}),
      Uri.parse('$baseUrl/guest/is_current.php').replace(queryParameters: {'guest_id': guestId, 'hotel_id': hotelId}),
    ];
    for (final uri in candidates) {
      try {
        final resp = await http.get(uri);
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          if (data is Map && data['active'] != null) {
            final v = data['active'];
            return v == true || v == 1 || v == '1' || (v is String && v.toLowerCase() == 'true');
          }
        }
      } catch (_) {}
    }
    return false; // default unknown -> not active
  }

  Future<void> checkInGuest({required String hotelId, required String guestId, required String roomNumber}) async {
    final payload = {
      'hotel_id': hotelId,
      'guest_id': guestId,
      'room': roomNumber,
      'status': 'active',
      'ts': DateTime.now().toIso8601String(),
    };
    final paths = [
      '$baseUrl/hotel_guests/checkin.php',
      '$baseUrl/guest/checkin.php',
      '$baseUrl/guests/checkin.php',
    ];
    http.Response? last;
    for (final p in paths) {
      try {
        last = await http.post(Uri.parse(p), headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
        if (last.statusCode == 200) return;
        // try form
        last = await http.post(Uri.parse(p), body: payload.map((k, v) => MapEntry(k, v.toString())));
        if (last.statusCode == 200) return;
      } catch (_) {}
    }
    throw Exception('Failed to check in guest (${last?.statusCode ?? 'unknown'})');
  }

  Future<void> checkOutGuest({required String hotelId, required String guestId}) async {
    final payload = {
      'hotel_id': hotelId,
      'guest_id': guestId,
      'status': 'inactive',
      'ts': DateTime.now().toIso8601String(),
    };
    final paths = [
      '$baseUrl/hotel_guests/checkout.php',
      '$baseUrl/guest/checkout.php',
      '$baseUrl/guests/checkout.php',
    ];
    http.Response? last;
    for (final p in paths) {
      try {
        last = await http.post(Uri.parse(p), headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
        if (last.statusCode == 200) return;
        last = await http.post(Uri.parse(p), body: payload.map((k, v) => MapEntry(k, v.toString())));
        if (last.statusCode == 200) return;
      } catch (_) {}
    }
    throw Exception('Failed to check out guest (${last?.statusCode ?? 'unknown'})');
  }
}
