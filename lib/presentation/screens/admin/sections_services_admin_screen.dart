// lib/presentation/screens/admin/sections_services_admin_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../data/models/section.dart';
import '../../../data/repositories/services_repository.dart';

class SectionsServicesAdminScreen extends StatelessWidget {
  static const routeName = '/admin/sections';
  final String hotelId;

  const SectionsServicesAdminScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    final repo = ServicesRepository();
    final lang = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(tr('admin.sections_services.title'))),
      body: StreamBuilder<List<Section>>(
        stream: repo.streamRootSectionsActive(hotelId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final sections = snapshot.data ?? const <Section>[];

          if (sections.isEmpty) {
            return Center(child: Text(tr('admin.sections_services.empty')));
          }

          return ListView.separated(
            itemCount: sections.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = sections[i];
              final title = s.name.resolve(lang);

              return ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(title),
                subtitle: (s.imageUrl != null && s.imageUrl!.isNotEmpty)
                    ? Text(s.imageUrl!)
                    : null,
                onTap: () {
                  // TODO: صفحة تفاصيل القسم + CRUD خدماته
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(tr('todo.soon'))));
                },
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: نافذة إنشاء قسم/خدمة
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(tr('todo.soon'))));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
