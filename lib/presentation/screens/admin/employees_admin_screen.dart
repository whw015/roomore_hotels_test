import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_routes.dart';
import '../../../cubits/employees/employees_cubit.dart';
import '../../../data/repositories/employee_repository.dart';

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
        body: Builder(
          builder: (innerContext) => ListTileTheme(
            data: ListTileThemeData(
              textColor: Theme.of(innerContext).colorScheme.onSurface,
              iconColor: Theme.of(innerContext).colorScheme.onSurface,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                await innerContext.read<EmployeesCubit>().load(hotelId: hotelId);
              if (!innerContext.mounted) return;
              final err = innerContext.read<EmployeesCubit>().state.error;
              final msg = err ?? tr('common.refreshed');
              ScaffoldMessenger.of(
                innerContext,
              ).showSnackBar(SnackBar(content: Text(msg)));
            },
            child: BlocBuilder<EmployeesCubit, EmployeesState>(
              builder: (context, state) {
                if (state.loading) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 0)],
                  );
                }
                if (state.error != null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 24),
                      Center(child: Text(state.error!)),
                    ],
                  );
                }
                if (state.list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 24),
                      Center(child: Text(tr('admin.employees.empty'))),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.list.length,
                  separatorBuilder: (_, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = state.list[i];
                    final String? avatar = e.avatarUrl;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (avatar != null && avatar.isNotEmpty)
                            ? NetworkImage(avatar)
                            : const AssetImage(
                                    'assets/images/avatar_placeholder.png',
                                  )
                                  as ImageProvider,
                        child: (avatar == null || avatar.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        e.fullName.isEmpty
                            ? tr('admin.sections_services.employees.no_name')
                            : e.fullName,
                      ),
                      subtitle: Text(
                        [
                          if (e.title != null && e.title!.isNotEmpty) e.title!,
                          e.email,
                          e.phone,
                        ].join(' � '),
                      ),
                      trailing: e.isActive
                          ? const Icon(Icons.verified, color: Colors.green)
                          : const Icon(Icons.block, color: Colors.red),
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          '/admin/employees/details',
                          arguments: {'employee': e},
                        );
                        if (!context.mounted) return;
                        if (result is Map &&
                            (result['updated'] != null ||
                                result['deleted'] == true)) {
                          context.read<EmployeesCubit>().load(hotelId: hotelId);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        ),
        floatingActionButton: Builder(
          builder: (innerContext) => FloatingActionButton(
            onPressed: () async {
              final created = await Navigator.of(innerContext).pushNamed(
                AppRoutes.employeesAdd,
                arguments: {'hotelId': hotelId},
              );
              if (!innerContext.mounted) return;
              if (created == true) {
                innerContext.read<EmployeesCubit>().load(hotelId: hotelId);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
