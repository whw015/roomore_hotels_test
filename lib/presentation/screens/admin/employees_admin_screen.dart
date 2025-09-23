import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmployeesAdminScreen extends StatelessWidget {
  static const routeName = '/admin/employees';
  const EmployeesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('admin.employees.title'))),
      body: Center(child: Text(tr('todo.soon'))),
    );
  }
}
