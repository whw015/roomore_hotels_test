// lib/presentation/widgets/home_sections_grid.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:roomore_hotels_test/app_routes.dart';
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
                onTap: () => Navigator.of(context).pushNamed('/admin/guests', arguments: {'hotelId': hotelId}),
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
                  childAspectRatio: 1,
                ),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final s = sections[index];
                  final title = s.name.resolve(lang);

                  final spec = _iconSpecFor(title, index, colors);
                  return Material(
                    elevation: 3,
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          InteriorServicesScreen.routeName,
                          arguments: {
                            'hotelId': hotelId,
                            'rootSectionId': s.id,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: spec.bg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(spec.icon, color: spec.fg, size: 28),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

class _IconSpec {
  final IconData icon;
  final Color fg;
  final Color bg;
  _IconSpec(this.icon, this.fg, this.bg);
}

_IconSpec _iconSpecFor(String title, int index, ColorScheme scheme) {
  final t = title.toLowerCase();
  // Arabic/English keyword guesses
  if (t.contains('فندق') || t.contains('hotel')) {
    return _IconSpec(Icons.room_service_outlined, const Color(0xFF1877F2), const Color(0x331877F2));
  }
  if (t.contains('متاجر') || t.contains('stores') || t.contains('shop')) {
    return _IconSpec(Icons.shopping_cart_outlined, const Color(0xFF2E7D32), const Color(0x332E7D32));
  }
  if (t.contains('تأجير') || t.contains('سيارات') || t.contains('cars')) {
    return _IconSpec(Icons.directions_car_filled_outlined, const Color(0xFFF9A825), const Color(0x33F9A825));
  }
  if (t.contains('الأماكن') || t.contains('سياح') || t.contains('places')) {
    return _IconSpec(Icons.place_outlined, const Color(0xFF8E24AA), const Color(0x338E24AA));
  }
  if (t.contains('فعاليات') || t.contains('events')) {
    return _IconSpec(Icons.event_outlined, const Color(0xFFE53935), const Color(0x33E53935));
  }
  if (t.contains('حجوز') || t.contains('bookings')) {
    return _IconSpec(Icons.bookmark_border, const Color(0xFF0277BD), const Color(0x330277BD));
  }
  if (t.contains('غرف') || t.contains('rooms')) {
    return _IconSpec(Icons.meeting_room_outlined, const Color(0xFF5E35B1), const Color(0x335E35B1));
  }
  // Fallback cycling palette
  const colors = [
    Color(0xFF1976D2),
    Color(0xFF2E7D32),
    Color(0xFFF9A825),
    Color(0xFF8E24AA),
    Color(0xFFE53935),
    Color(0xFF0277BD),
  ];
  final c = colors[index % colors.length];
  return _IconSpec(Icons.widgets_outlined, c, c.withOpacity(0.2));
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






