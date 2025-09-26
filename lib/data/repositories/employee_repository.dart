// lib/data/repositories/employee_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:roomore_hotels_test/data/models/employee.dart';
import 'package:roomore_hotels_test/data/repositories/api_repository.dart';
import 'package:roomore_hotels_test/config/env.dart';

class EmployeeRepository extends ApiRepository {
  EmployeeRepository();

  Future<List<Employee>> fetchAll({required String hotelId}) async {
    // Prefer one endpoint and fallback to the other on 404/405
    // Production has get_employees.php; prefer it in both modes
    final cacheBust = DateTime.now().millisecondsSinceEpoch.toString();
    final preferred = Uri.parse('$baseUrl/employees/get_employees.php').replace(
      queryParameters: {
        'code': hotelId,
        '_ts': cacheBust,
      },
    );
    final alternate = Uri.parse('$baseUrl/employees/list.php').replace(
      queryParameters: {
        'code': hotelId,
        '_ts': cacheBust,
      },
    );

    http.Response resp = await http.get(preferred);
    if (resp.statusCode == 404 || resp.statusCode == 405) {
      resp = await http.get(alternate);
    }
    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to load employees (${resp.statusCode}) from ${preferred.path}');
    }
    final data = json.decode(resp.body);
    final list = (data is Map && data['employees'] is List)
        ? data['employees'] as List
        : (data is Map && data['data'] is List)
        ? data['data'] as List
        : (data is List)
        ? data
        : <dynamic>[];
    return list
        .whereType<Map>()
        .map((e) => _normalizeEmployeeJson(Map<String, dynamic>.from(e)))
        .map(Employee.fromJson)
        .toList();
  }

  Future<Employee> createEmployee({
    required String hotelId,
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String nationality,
    DateTime? birthDate,
    String? idNumber,
    String? avatarUrl,
    String? title,
    String? employeeNo,
    required String workgroup,
    required bool isActive,
  }) async {
    // Try two endpoint variants with automatic fallback
    http.Response resp;
    Map<String, dynamic>? sentPayload;
    // Production has add_employee.php; prefer it in both modes
    final firstUri = Uri.parse('$baseUrl/employees/add_employee.php');
    final secondUri = Uri.parse('$baseUrl/employees/create.php');

    // First attempt
    if (firstUri.path.endsWith('add_employee.php')) {
      final payload = <String, dynamic>{
        'name': fullName,
        'email': email,
        'phone': phone,
        'gender': gender,
        'nationality': nationality,
        if (birthDate != null) 'dob': birthDate.toIso8601String(),
        if (idNumber != null) 'id_number': idNumber,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (title != null) 'job_title': title,
        if (employeeNo != null) 'employee_id': employeeNo,
        'workgroup': workgroup,
        'is_active': isActive ? 1 : 0,
        'hotel_id': hotelId,
      };
      sentPayload = payload;
      resp = await http.post(
        firstUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
    } else {
      final form = {
        'hotel_id': hotelId,
        'hotelId': hotelId,
        'full_name': fullName,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'gender': gender,
        'nationality': nationality,
        if (birthDate != null) 'birthdate': birthDate.toIso8601String(),
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        if (idNumber != null) 'id_number': idNumber,
        if (idNumber != null) 'idNumber': idNumber,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (title != null) 'title': title,
        if (employeeNo != null) 'employee_no': employeeNo,
        if (employeeNo != null) 'employeeNo': employeeNo,
        'workgroup': workgroup,
        'is_active': isActive ? '1' : '0',
        'isActive': isActive ? '1' : '0',
      };
      sentPayload = form;
      resp = await http.post(firstUri, body: form);
    }

    // Fallback on not found/method not allowed
    if (resp.statusCode == 404 || resp.statusCode == 405) {
      if (secondUri.path.endsWith('add_employee.php')) {
        final payload = <String, dynamic>{
          'name': fullName,
          'email': email,
          'phone': phone,
          'gender': gender,
          'nationality': nationality,
          if (birthDate != null) 'dob': birthDate.toIso8601String(),
          if (idNumber != null) 'id_number': idNumber,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (title != null) 'job_title': title,
          if (employeeNo != null) 'employee_id': employeeNo,
          'workgroup': workgroup,
          'is_active': isActive ? 1 : 0,
          'hotel_id': hotelId,
        };
        sentPayload = payload;
        resp = await http.post(
          secondUri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );
      } else {
        final form = {
          'hotel_id': hotelId,
          'hotelId': hotelId,
          'full_name': fullName,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'gender': gender,
          'nationality': nationality,
          if (birthDate != null) 'birthdate': birthDate.toIso8601String(),
          if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
          if (idNumber != null) 'id_number': idNumber,
          if (idNumber != null) 'idNumber': idNumber,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
          if (title != null) 'title': title,
          if (employeeNo != null) 'employee_no': employeeNo,
          if (employeeNo != null) 'employeeNo': employeeNo,
          'workgroup': workgroup,
          'is_active': isActive ? '1' : '0',
          'isActive': isActive ? '1' : '0',
        };
        sentPayload = form;
        resp = await http.post(secondUri, body: form);
      }
    }

    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to create employee (${resp.statusCode}) at ${firstUri.path}');
    }
    final data = json.decode(resp.body);
    final map = (data is Map && data['employee'] is Map)
        ? Map<String, dynamic>.from(data['employee'] as Map)
        : (data is Map)
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    final normalized = _normalizeEmployeeJson(
      map.isEmpty ? (sentPayload) : map,
    );
    return Employee.fromJson(normalized);
  }

  Future<String> uploadAvatar(File file) async {
    final uri = Uri.parse(Env.uploadsBaseUrl);
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      throw Exception('Failed to upload image (${resp.statusCode})');
    }
    final data = json.decode(resp.body);
    final url = (data is Map && data['url'] is String)
        ? data['url'] as String
        : (data is Map && data['path'] is String)
        ? data['path'] as String
        : resp.body; // fallback
    return url;
  }

  Map<String, dynamic> _normalizeEmployeeJson(Map<String, dynamic> json) {
    return {
      'id': (json['id'] ?? json['employee_id'] ?? '').toString(),
      'hotelId':
          (json['hotelId'] ?? json['hotel_id'] ?? json['hotelCode'] ?? '')
              .toString(),
      'fullName': (json['fullName'] ?? json['full_name'] ?? json['name'] ?? '')
          .toString(),
      'email': (json['email'] ?? '').toString(),
      'phone': (json['phone'] ?? '').toString(),
      'gender': (json['gender'] ?? '').toString(),
      'nationality': (json['nationality'] ?? '').toString(),
      'birthDate': json['birthDate'] ?? json['birthdate'] ?? json['dob'],
      'idNumber': json['idNumber'] ?? json['id_number'],
      'avatarUrl': json['avatarUrl'] ?? json['avatar_url'],
      'title': json['title'] ?? json['job_title'],
      'employeeNo':
          json['employeeNo'] ?? json['employee_no'] ?? json['employee_id'],
      'workgroup': (json['workgroup'] ?? '').toString(),
      'isActive': json['isActive'] ?? json['is_active'] ?? json['active'] ??
          (json['status'] != null
              ? (json['status'].toString() == 'active' || json['status'].toString() == '1' || json['status'].toString().toLowerCase() == 'true')
              : true),
    };
  }
  Future<Employee> updateEmployee({
    required String id,
    required String hotelId,
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String nationality,
    DateTime? birthDate,
    String? idNumber,
    String? avatarUrl,
    String? title,
    String? employeeNo,
    required String workgroup,
    required bool isActive,
  }) async {
    final uri = Uri.parse('$baseUrl/employees/update_employee.php');
    final payload = <String, dynamic>{
      'id': id,
      'hotel_id': hotelId,
      'name': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'nationality': nationality,
      if (birthDate != null) 'dob': birthDate.toIso8601String(),
      if (idNumber != null) 'id_number': idNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (title != null) 'job_title': title,
      if (employeeNo != null) 'employee_id': employeeNo,
      'workgroup': workgroup,
      'is_active': isActive ? 1 : 0,
    };
    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode(payload));
    if (resp.statusCode != 200) {
      throw Exception('Failed to update employee (${resp.statusCode})');
    }
    final data = json.decode(resp.body);
    if (data is Map && data['ok'] == false && data['error'] is String) {
      throw Exception(data['error'].toString());
    }
    final map = (data is Map && data['employee'] is Map)
        ? Map<String, dynamic>.from(data['employee'] as Map)
        : (data is Map)
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};
    final normalized = _normalizeEmployeeJson(map);
    return Employee.fromJson(normalized);
  }

  Future<void> deleteEmployee({required String id}) async {
    final uri = Uri.parse('$baseUrl/employees/delete_employee.php');
    final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: json.encode({'id': id}));
    if (resp.statusCode != 200) {
      throw Exception('Failed to delete employee (${resp.statusCode})');
    }
    try {
      final data = json.decode(resp.body);
      if (data is Map && data['ok'] == false && data['error'] is String) {
        throw Exception(data['error'].toString());
      }
    } catch (_) {}
  }
}



