// lib/cubits/employees/employees_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/employee.dart';
import '../../data/repositories/employee_repository.dart';

class EmployeesState extends Equatable {
  final bool loading;
  final List<Employee> list;
  final String? error;

  const EmployeesState({required this.loading, required this.list, this.error});

  factory EmployeesState.initial() =>
      const EmployeesState(loading: false, list: <Employee>[]);

  EmployeesState copyWith({
    bool? loading,
    List<Employee>? list,
    String? error,
  }) {
    return EmployeesState(
      loading: loading ?? this.loading,
      list: list ?? this.list,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, list, error];
}

class EmployeesCubit extends Cubit<EmployeesState> {
  final EmployeeRepository _repo;

  EmployeesCubit(this._repo) : super(EmployeesState.initial());

  Future<void> load({required String hotelId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await _repo.fetchAll(hotelId: hotelId);
      emit(state.copyWith(loading: false, list: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
