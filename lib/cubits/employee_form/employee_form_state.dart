import '../../../data/models/employee.dart';

sealed class EmployeeFormState {
  const EmployeeFormState();
}

class EmployeeFormIdle extends EmployeeFormState {
  const EmployeeFormIdle();
}

class EmployeeFormSubmitting extends EmployeeFormState {
  const EmployeeFormSubmitting();
}

class EmployeeFormSuccess extends EmployeeFormState {
  final Employee created;
  const EmployeeFormSuccess(this.created);
}

class EmployeeFormError extends EmployeeFormState {
  final String message;
  const EmployeeFormError(this.message);
}
