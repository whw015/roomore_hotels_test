part of 'employees_cubit.dart';

sealed class EmployeesState extends Equatable {
  const EmployeesState();
  @override
  List<Object?> get props => [];
}

class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
}

class EmployeesError extends EmployeesState {
  final String message;
  const EmployeesError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeesData extends EmployeesState {
  final List<dynamic> list; // استبدلها بنوع Employee لديك
  const EmployeesData(this.list);
  @override
  List<Object?> get props => [list];
}
