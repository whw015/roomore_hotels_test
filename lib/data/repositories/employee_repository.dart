// lib/data/repositories/employee_repository.dart
import 'dart:async';

import 'package:roomore_hotels_test/data/models/employee.dart';
import 'package:roomore_hotels_test/data/repositories/api_repository.dart';

class EmployeeRepository extends ApiRepository {
  // لا نمرر أي بارامترات للـ super لأن ApiRepository يضبط baseUrl افتراضيًا
  EmployeeRepository();

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
    // لاحقًا اربطه بـ POST فعلي، الآن نُرجع كائن تجريبي
    return Employee(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotelId: hotelId,
      fullName: fullName,
      email: email,
      phone: phone,
      gender: gender,
      nationality: nationality,
      birthDate: birthDate,
      idNumber: idNumber,
      avatarUrl: avatarUrl,
      title: title,
      employeeNo: employeeNo,
      workgroup: workgroup,
      isActive: isActive,
      // ملاحظة: لا نمرر createdAt / updatedAt لأنها غير موجودة في الـ model لديك
    );
  }

  Future<List<Employee>> fetchAll({required String hotelId}) async {
    // مثال ربط مستقبلاً:
    // GET: $baseUrl/employees/list.php?code=$hotelId
    return <Employee>[];
  }
}
