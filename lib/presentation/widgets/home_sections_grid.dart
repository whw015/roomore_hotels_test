// lib/presentation/widgets/home_sections_grid.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../screens/interior_services_screen.dart';
import '../../data/models/section.dart';
import '../../data/repositories/services_repository.dart';

class HomeSectionsGrid extends StatelessWidget {
  final String hotelId;

  const HomeSectionsGrid({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    final repo = ServicesRepository();
    final lang = context.locale.languageCode;

    // ignore: unrelated_type_equality_checks
    final isRTL = Directionality.of(context) == TextDirection.RTL;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        // صف أزرار الإدارة السريعة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _AdminChip(
                icon: Icons.people_alt_outlined,
                label: tr('home.admin.employees'),
                background: colors.primaryContainer,
                foreground: colors.onPrimaryContainer,
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.adminEmployees,
                  arguments: {'hotelId': hotelId},
                ),
              ),
              _AdminChip(
                icon: Icons.group_work_outlined,
                label: tr('home.admin.workgroups'),
                background: colors.secondaryContainer,
                foreground: colors.onSecondaryContainer,
                onTap: () =>
                    Navigator.of(context).pushNamed('/admin/workgroups'),
              ),
              _AdminChip(
                icon: Icons.bed_outlined,
                label: tr('home.admin.guests'),
                background: colors.tertiaryContainer,
                foreground: colors.onTertiaryContainer,
                onTap: () => Navigator.of(context).pushNamed('/admin/guests'),
              ),
              _AdminChip(
                icon: Icons.folder_open,
                label: tr('home.admin.sections'),
                background: colors.surfaceContainerHighest,
                foreground: colors.onSurface,
                onTap: () => Navigator.of(context).pushNamed(
                  '/admin/sections',
                  arguments: {'hotelId': hotelId}, // أو تمرير String مباشرة
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // قائمة الأقسام الرئيسية
        Expanded(
          child: StreamBuilder<List<Section>>(
            stream: repo.streamRootSectionsActive(hotelId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final sections = snapshot.data ?? const <Section>[];
              if (sections.isEmpty) {
                return Center(child: Text(tr('home.sections.empty')));
              }

              final gridCount = MediaQuery.of(context).size.width >= 600
                  ? 3
                  : 2;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isRTL ? 1.05 : 1.05,
                ),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final s = sections[index];
                  final title = s.name.resolve(lang);

                  return Card(
                    elevation: 1,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          InteriorServicesScreen.routeName,
                          arguments: {
                            'hotelId': hotelId,
                            'rootSectionId': s.id,
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (s.imageUrl != null && s.imageUrl!.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                s.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, st) => const ColoredBox(
                                  color: Colors.black12,
                                  child: Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 6),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: isRTL
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chevron_right,
                                    color: colors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _AdminChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
