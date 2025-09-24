import 'package:equatable/equatable.dart';
import '../../data/models/employee.dart';

sealed class EmployeesState extends Equatable {
  const EmployeesState();
  @override
  List<Object?> get props => [];
}

class EmployeesInitial extends EmployeesState {
  const EmployeesInitial();
}

class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
}

class EmployeesLoaded extends EmployeesState {
  final List<Employee> employees;
  const EmployeesLoaded(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeesError extends EmployeesState {
  final String message;
  const EmployeesError(this.message);

  @override
  List<Object?> get props => [message];
}
