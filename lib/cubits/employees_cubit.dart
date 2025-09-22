import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/api_repository.dart';

class EmployeesState extends Equatable {
  final bool isLoading;
  final List employees;
  final String? error;

  const EmployeesState({
    this.isLoading = false,
    this.employees = const [],
    this.error,
  });

  EmployeesState copyWith({bool? isLoading, List? employees, String? error}) {
    return EmployeesState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, employees, error];
}

class EmployeesCubit extends Cubit<EmployeesState> {
  final ApiRepository apiRepository;

  EmployeesCubit(this.apiRepository) : super(const EmployeesState()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await apiRepository.getEmployees();
      emit(state.copyWith(isLoading: false, employees: response['employees']));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addEmployee(Map<String, dynamic> data) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.addEmployee(data);
      await fetchEmployees();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteEmployee(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await apiRepository.deleteEmployee(id);
      await fetchEmployees();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
