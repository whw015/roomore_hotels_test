import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiRepository {
  final String baseUrl = 'https://brq25.com/roomore-api/api/public';

  Future<Map<String, dynamic>> checkEmployee(
    String userId,
    String qrCode,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees/check_employee.php'),
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
        '$baseUrl/employees/get_user_group_services.php?user_id=$userId&hotel_id=$hotelId',
      ),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data');
    }
  }

  Future<Map<String, dynamic>> getSections() async {
    final response = await http.get(
      Uri.parse('$baseUrl/sections/get_sections.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch sections');
    }
  }

  Future<void> addSection(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sections/add_section.php'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add section');
    }
  }

  Future<void> deleteSection(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sections/delete_section.php'),
      body: {'id': id},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete section');
    }
  }

  Future<Map<String, dynamic>> getEmployees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/employees/get_employee.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch employees');
    }
  }

  Future<void> addEmployee(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees/add_employee.php'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add employee');
    }
  }

  Future<void> deleteEmployee(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employees/delete_employee.php'),
      body: {'id': id},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }

  Future<Map<String, dynamic>> getWorkGroups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/work_group/get_work_group.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch work groups');
    }
  }

  Future<void> addWorkGroup(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/work_group/add_work_group.php'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add work group');
    }
  }

  Future<void> deleteWorkGroup(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/work_group/delete_work_group.php'),
      body: {'id': id},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete work group');
    }
  }

  Future<Map<String, dynamic>> getGuests() async {
    final response = await http.get(Uri.parse('$baseUrl/guest/get_guest.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch guests');
    }
  }

  Future<void> addGuest(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guest/add_guest.php'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add guest');
    }
  }

  Future<void> deleteGuest(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/guest/delete_guest.php'),
      body: {'id': id},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete guest');
    }
  }
}
