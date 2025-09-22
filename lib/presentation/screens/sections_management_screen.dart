import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/sections_cubit.dart';
import '../../data/repositories/api_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class SectionsManagementScreen extends StatelessWidget {
  const SectionsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SectionsCubit(ApiRepository())..fetchSections(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('manage_sections'.tr(), style: AppTheme.appBarText),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<SectionsCubit, SectionsState>(
          builder: (context, state) {
            return state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAddSectionForm(context),
                      const SizedBox(height: 16),
                      ...state.sections.map(
                        (section) => _buildSectionItem(context, section),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAddSectionForm(BuildContext context) {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    final descArController = TextEditingController();
    final descEnController = TextEditingController();
    final priceController = TextEditingController();

    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('add_section'.tr(), style: AppTheme.subTitle),
            TextField(
              controller: nameArController,
              decoration: InputDecoration(labelText: 'section_name_ar'.tr()),
            ),
            TextField(
              controller: nameEnController,
              decoration: InputDecoration(labelText: 'section_name_en'.tr()),
            ),
            TextField(
              controller: descArController,
              decoration: InputDecoration(labelText: 'description_ar'.tr()),
            ),
            TextField(
              controller: descEnController,
              decoration: InputDecoration(labelText: 'description_en'.tr()),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'price_sar'.tr()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  context.read<SectionsCubit>().addSection({
                    'name_ar': nameArController.text,
                    'name_en': nameEnController.text,
                    'desc_ar': descArController.text,
                    'desc_en': descEnController.text,
                    'price': priceController.text,
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

  Widget _buildSectionItem(BuildContext context, dynamic section) {
    return Card(
      color: AppColors.white,
      child: ListTile(
        title: Text(section['name_ar'] ?? '', style: AppTheme.bodyText),
        subtitle: Text('${section['price'] ?? 0} SAR', style: AppTheme.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                // منطق التعديل
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                if (context.mounted) {
                  context.read<SectionsCubit>().deleteSection(
                    section['id'].toString(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
