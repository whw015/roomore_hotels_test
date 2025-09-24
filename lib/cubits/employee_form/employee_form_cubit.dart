// lib/cubits/employee_form/employee_form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:roomore_hotels_test/data/repositories/employee_repository.dart';

class EmployeeFormState extends Equatable {
  final bool submitting;
  final bool success;
  final String? error;

  const EmployeeFormState({
    required this.submitting,
    required this.success,
    this.error,
  });

  factory EmployeeFormState.initial() =>
      const EmployeeFormState(submitting: false, success: false);

  EmployeeFormState copyWith({bool? submitting, bool? success, String? error}) {
    return EmployeeFormState(
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [submitting, success, error];
}

class EmployeeFormCubit extends Cubit<EmployeeFormState> {
  final EmployeeRepository _repo;

  EmployeeFormCubit(this._repo) : super(EmployeeFormState.initial());

  Future<void> submit({
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
    emit(state.copyWith(submitting: true, success: false, error: null));
    try {
      await _repo.createEmployee(
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
      );
      emit(state.copyWith(submitting: false, success: true));
    } catch (e) {
      emit(
        state.copyWith(submitting: false, success: false, error: e.toString()),
      );
    }
  }
}
