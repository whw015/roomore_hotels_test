import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roomore_hotels_test/cubits/employees/employees_cubit.dart';
import 'package:roomore_hotels_test/data/repositories/employee_repository.dart';

import '../../../app_routes.dart';

class EmployeesAdminScreen extends StatelessWidget {
  static const routeName = '/admin/employees';
  final String hotelId;

  const EmployeesAdminScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          EmployeesCubit(EmployeeRepository())..load(hotelId: hotelId),
      child: Scaffold(
        appBar: AppBar(title: Text(tr('admin.employees.title'))),
        body: BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text(state.error!));
            }
            if (state.list.isEmpty) {
              return Center(child: Text(tr('admin.employees.empty')));
            }
            return ListView.separated(
              itemCount: state.list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final e = state.list[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(e.fullName),
                  subtitle: Text(
                    [
                      if (e.title != null && e.title!.isNotEmpty) e.title!,
                      e.email,
                      e.phone,
                    ].join(' • '),
                  ),
                  trailing: e.isActive
                      ? const Icon(Icons.verified, color: Colors.green)
                      : const Icon(Icons.block, color: Colors.red),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              AppRoutes.employeesAdd,
              arguments: {'hotelId': hotelId}, // لا ترسل String فقط
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
