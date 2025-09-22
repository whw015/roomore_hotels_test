import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../cubits/home/home_cubit.dart' as home_cubit;
import '../../data/repositories/auth_repository.dart';
import '../widgets/home_qr_center.dart';
import 'home_sections_grid.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('home'.tr())),
      body: BlocBuilder<home_cubit.HomeCubit, home_cubit.HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isQrVerified) {
            return const HomeSectionsGrid();
          }
          final controller = TextEditingController();
          return HomeQrCenter(
            message: tr('scan_qr_code'),
            controller: controller,
            onConfirm: (qrCode) {
              if (context.mounted) {
                final user = context.read<AuthRepository>().currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(tr('error.no_user'))));
                  return;
                }
                context.read<home_cubit.HomeCubit>().verifyQrCode(
                  qrCode,
                  user.uid, // استبدلت id بـ uid
                );
              }
            },
          );
        },
      ),
    );
  }
}
