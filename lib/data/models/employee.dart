// lib/data/models/employee.dart
class Employee {
  final String id; // يُولّد من الباك لاحقاً
  final String hotelId;
  final String fullName;
  final String email;
  final String phone;
  final String gender; // 'male' | 'female' | ...
  final String nationality; // ISO 3166-1 alpha-2 (SA, EG, ...)
  final DateTime? birthDate; // تاريخ الميلاد
  final String? idNumber; // رقم الهوية
  final String? avatarUrl; // رابط صورة الموظف
  final String? title; // المسمى الوظيفي
  final String? employeeNo; // الرقم الوظيفي
  final String workgroup; // اسم أو كود مجموعة العمل
  final bool isActive;

  const Employee({
    required this.id,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.nationality,
    this.birthDate,
    this.idNumber,
    this.avatarUrl,
    this.title,
    this.employeeNo,
    required this.workgroup,
    required this.isActive,
  });

  factory Employee.empty({required String hotelId}) => Employee(
    id: '',
    hotelId: hotelId,
    fullName: '',
    email: '',
    phone: '',
    gender: 'male',
    nationality: 'SA',
    birthDate: null,
    idNumber: null,
    avatarUrl: null,
    title: null,
    employeeNo: null,
    workgroup: 'staff',
    isActive: true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'nationality': nationality,
    'birthDate': birthDate?.toIso8601String(),
    'idNumber': idNumber,
    'avatarUrl': avatarUrl,
    'title': title,
    'employeeNo': employeeNo,
    'workgroup': workgroup,
    'isActive': isActive,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: (json['id'] ?? '').toString(),
    hotelId: (json['hotelId'] ?? '').toString(),
    fullName: (json['fullName'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    gender: (json['gender'] ?? '').toString(),
    nationality: (json['nationality'] ?? '').toString(),
    birthDate: json['birthDate'] == null
        ? null
        : DateTime.tryParse(json['birthDate'].toString()),
    idNumber: json['idNumber']?.toString(),
    avatarUrl: json['avatarUrl']?.toString(),
    title: json['title']?.toString(),
    employeeNo: json['employeeNo']?.toString(),
    workgroup: (json['workgroup'] ?? 'staff').toString(),
    isActive: json['isActive'] is bool
        ? json['isActive'] as bool
        : json['isActive']?.toString() == '1',
  );
}
