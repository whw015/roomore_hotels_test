import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/interior_services_screen.dart';
import '../cubits/home/home_cubit.dart';

class HomeSectionsGrid extends StatelessWidget {
  const HomeSectionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // نقرأ hotelId من HomeCubit عبر الحالة
    final String? hotelId = context.select<HomeCubit, String?>(
      (cubit) => cubit.state.stay?.hotelId,
    );

    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _SectionItem(
          icon: Icons.room_service_outlined,
          color: const Color(0xFF2196F3),
          label: tr('home.sections.services'),
          onTap: () {
            if (hotelId == null || hotelId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('common.missingHotelId'))),
              );
              return;
            }
            Navigator.pushNamed(
              context,
              InteriorServicesScreen.routeName,
              arguments: InteriorServicesArgs(
                hotelId: hotelId,
                title: tr('home.sections.services'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SectionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SectionItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
