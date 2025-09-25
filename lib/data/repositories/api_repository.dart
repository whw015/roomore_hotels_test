import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roomore_hotels_test/config/env.dart';

class ApiRepository {
  final String baseUrl = Env.apiBaseUrl;

  Future<Map<String, dynamic>> checkEmployee(
    String userId,
    String qrCode,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check_employee.php'),
      body: {'user_id': userId, 'qr_code': qrCode},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check employee');
    }
  }

  Future<Map<String, dynamic>> getUserGroupAndServices(
    String userId,
    String hotelId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/get_user_group_services.php?user_id=$userId&hotel_id=$hotelId',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data');
    }
  }

  // إضافة endpoints أخرى لاحقًا للشاشات الجديدة
}
