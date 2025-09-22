import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/work_groups_cubit.dart';
import '../../data/repositories/api_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class WorkGroupsManagementScreen extends StatelessWidget {
  const WorkGroupsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkGroupsCubit(ApiRepository())..fetchWorkGroups(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('manage_work_groups'.tr(), style: AppTheme.appBarText),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<WorkGroupsCubit, WorkGroupsState>(
          builder: (context, state) {
            return state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAddWorkGroupForm(context),
                      const SizedBox(height: 16),
                      ...state.workGroups.map(
                        (group) => _buildWorkGroupItem(context, group),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAddWorkGroupForm(BuildContext context) {
    final nameController = TextEditingController();
    final permissionsController = TextEditingController();

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('add_work_group'.tr(), style: AppTheme.subTitle),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'group_name'.tr()),
            ),
            TextField(
              controller: permissionsController,
              decoration: InputDecoration(labelText: 'permissions'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  context.read<WorkGroupsCubit>().addWorkGroup({
                    'name': nameController.text,
                    'permissions': permissionsController.text.split(','),
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'add'.tr(),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkGroupItem(BuildContext context, dynamic group) {
    return Card(
      color: AppColors.white,
      child: ListTile(
        title: Text(group['name'] ?? '', style: AppTheme.bodyText),
        subtitle: Text(
          group['permissions']?.join(', ') ?? '',
          style: AppTheme.caption,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            if (context.mounted) {
              context.read<WorkGroupsCubit>().deleteWorkGroup(
                group['id'].toString(),
              );
            }
          },
        ),
      ),
    );
  }
}
