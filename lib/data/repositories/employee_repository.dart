import 'dart:async';

class EmployeeProfile {
  final bool isAdmin;
  final List<String>
  permissions; // ex: ['sections.read','sections.write','items.write','employees.manage']
  final List<String> responsibleSectionIds; // أقسام مسؤول عنها
  const EmployeeProfile({
    required this.isAdmin,
    required this.permissions,
    required this.responsibleSectionIds,
  });
}

class EmployeeRepository {
  final String baseUrl;
  const EmployeeRepository({required this.baseUrl});

  /// التحقق من ان المستخدم موظف مرتبط بالفندق
  Future<EmployeeProfile?> verifyEmployee({
    required String hotelCode,
    required String userUid,
  }) async {
    // TODO: اربط بـ GET: $baseUrl/employees/me.php?code=$hotelCode&uid=$userUid
    // مؤقتاً نرجّع admin علشان تكمل UI:
    return const EmployeeProfile(
      isAdmin: true,
      permissions: [
        'sections.read',
        'sections.write',
        'items.write',
        'employees.manage',
        'guests.manage',
        'groups.manage',
      ],
      responsibleSectionIds: <String>[],
    );
  }
}
