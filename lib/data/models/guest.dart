class Guest {
  final String id;
  final String hotelId;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String nationality;
  final DateTime? birthDate;
  final String? idNumber;
  final String? jobTitle;
  final String? employeeId; // referring employee/staff who registered

  const Guest({
    required this.id,
    required this.hotelId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.nationality,
    this.birthDate,
    this.idNumber,
    this.jobTitle,
    this.employeeId,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: (json['id'] ?? json['guest_id'] ?? '').toString(),
      hotelId: (json['hotel_id'] ?? json['hotelId'] ?? '').toString(),
      fullName: (json['name'] ?? json['full_name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      nationality: (json['nationality'] ?? '').toString(),
      birthDate: json['dob'] != null
          ? DateTime.tryParse(json['dob'].toString())
          : (json['birthDate'] != null
              ? DateTime.tryParse(json['birthDate'].toString())
              : null),
      idNumber: json['id_number']?.toString(),
      jobTitle: json['job_title']?.toString(),
      employeeId: json['employee_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hotel_id': hotelId,
        'name': fullName,
        'email': email,
        'phone': phone,
        'gender': gender,
        'nationality': nationality,
        'dob': birthDate?.toIso8601String(),
        'id_number': idNumber,
        'job_title': jobTitle,
        'employee_id': employeeId,
      };
}

