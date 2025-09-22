import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/employees_cubit.dart';
import '../../data/repositories/api_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class EmployeesManagementScreen extends StatelessWidget {
  const EmployeesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmployeesCubit(ApiRepository())..fetchEmployees(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('manage_employees'.tr(), style: AppTheme.appBarText),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) {
            return state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAddEmployeeForm(context),
                      const SizedBox(height: 16),
                      ...state.employees.map(
                        (employee) => _buildEmployeeItem(context, employee),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAddEmployeeForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final genderController = TextEditingController();
    final nationalityController = TextEditingController();
    final dobController = TextEditingController();
    final idNumberController = TextEditingController();
    final jobTitleController = TextEditingController();
    final employeeIdController = TextEditingController();

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('add_employee'.tr(), style: AppTheme.subTitle),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'full_name'.tr()),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'email'.tr()),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'phone_number'.tr()),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(labelText: 'gender'.tr()),
            ),
            TextField(
              controller: nationalityController,
              decoration: InputDecoration(labelText: 'nationality'.tr()),
            ),
            TextField(
              controller: dobController,
              decoration: InputDecoration(labelText: 'date_of_birth'.tr()),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: idNumberController,
              decoration: InputDecoration(labelText: 'id_number'.tr()),
            ),
            TextField(
              controller: jobTitleController,
              decoration: InputDecoration(labelText: 'job_title'.tr()),
            ),
            TextField(
              controller: employeeIdController,
              decoration: InputDecoration(labelText: 'employee_id'.tr()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  context.read<EmployeesCubit>().addEmployee({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'gender': genderController.text,
                    'nationality': nationalityController.text,
                    'dob': dobController.text,
                    'id_number': idNumberController.text,
                    'job_title': jobTitleController.text,
                    'employee_id': employeeIdController.text,
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

  Widget _buildEmployeeItem(BuildContext context, dynamic employee) {
    return Card(
      color: AppColors.white,
      child: ListTile(
        title: Text(employee['name'] ?? '', style: AppTheme.bodyText),
        subtitle: Text(employee['job_title'] ?? '', style: AppTheme.caption),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            if (context.mounted) {
              context.read<EmployeesCubit>().deleteEmployee(
                employee['id'].toString(),
              );
            }
          },
        ),
      ),
    );
  }
}
