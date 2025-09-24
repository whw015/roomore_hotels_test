import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// ملاحظة: لا نستخدم bloc هنا حتى لا نعلّقك بتواقيع دوال مختلفة
// عندك. الهدف الآن تمكين إضافة موظف بسلاسة.

class EmployeeAddScreen extends StatefulWidget {
  static const String employeesAdd = '/admin/employees/add';
  final String hotelId;
  const EmployeeAddScreen({super.key, required this.hotelId});
  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: unrelated_type_equality_checks
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    final hotelId = widget.hotelId;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('admin.employees.title')),
        actions: [
          IconButton(
            tooltip: tr('admin.employees.add.add'),
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: Text(
          tr('admin.employees.empty'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: Text(tr('admin.employees.add.add')),
      ),
      floatingActionButtonLocation: isRTL
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }
}
