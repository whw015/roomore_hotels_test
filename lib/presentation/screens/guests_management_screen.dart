import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/guests_cubit.dart';
import '../../data/repositories/api_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class GuestsManagementScreen extends StatelessWidget {
  const GuestsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestsCubit(ApiRepository())..fetchGuests(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('manage_guests'.tr(), style: AppTheme.appBarText),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<GuestsCubit, GuestsState>(
          builder: (context, state) {
            return state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAddGuestForm(context),
                      const SizedBox(height: 16),
                      ...state.guests.map(
                        (guest) => _buildGuestItem(context, guest),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAddGuestForm(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final genderController = TextEditingController();
    final nationalityController = TextEditingController();
    final dobController = TextEditingController();
    final idNumberController = TextEditingController();
    final arrivalDateController = TextEditingController();

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('add_guest'.tr(), style: AppTheme.subTitle),
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
              controller: arrivalDateController,
              decoration: InputDecoration(labelText: 'arrival_date'.tr()),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  context.read<GuestsCubit>().addGuest({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'gender': genderController.text,
                    'nationality': nationalityController.text,
                    'dob': dobController.text,
                    'id_number': idNumberController.text,
                    'arrival_date': arrivalDateController.text,
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

  Widget _buildGuestItem(BuildContext context, dynamic guest) {
    return Card(
      color: AppColors.white,
      child: ListTile(
        title: Text(guest['name'] ?? '', style: AppTheme.bodyText),
        subtitle: Text(guest['email'] ?? '', style: AppTheme.caption),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            if (context.mounted) {
              context.read<GuestsCubit>().deleteGuest(guest['id'].toString());
            }
          },
        ),
      ),
    );
  }
}
