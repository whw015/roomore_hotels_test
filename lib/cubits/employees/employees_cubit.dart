import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/employee_repository.dart';

part 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final String hotelId;
  final EmployeeRepository _repo;

  // قاعدة الـ API الافتراضية (بدلاً من نسيان تمريرها)
  static const String _defaultApiBaseUrl =
      'https://brq25.com/roomore-api/api/public';

  EmployeesCubit({required this.hotelId, String? baseUrl})
    : _repo = EmployeeRepository(baseUrl: baseUrl ?? _defaultApiBaseUrl),
      super(const EmployeesLoading());

  Future<void> load() async {
    emit(const EmployeesLoading());
    try {
      final list = await _repo.fetchAll(hotelId: hotelId); // معرّفة في الامتداد
      emit(EmployeesData(list));
    } catch (e) {
      emit(EmployeesError(e.toString()));
    }
  }
}
