import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../cubits/employees/employees_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeesAdminScreen extends StatelessWidget {
  static const routeName = '/admin/employees';
  final String hotelId;
  const EmployeesAdminScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeesCubit(hotelId: hotelId)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(tr('admin.employees.title'))),
        body: BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) {
            return switch (state) {
              EmployeesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              EmployeesError(message: final m) => Center(child: Text(m)),
              EmployeesData(list: final employees) => ListView.separated(
                itemCount: employees.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = employees[i];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      e.fullName ?? e.email ?? tr('admin.employees.no_name'),
                    ),
                    subtitle: Text(e.workGroupCode ?? '-'),
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(tr('todo.soon'))));
                    },
                  );
                },
              ),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(tr('todo.soon'))));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
