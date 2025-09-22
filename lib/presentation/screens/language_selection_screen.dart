import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/app_colors.dart';
import '../../cubits/app_flow/app_flow_cubit.dart';
import '../../cubits/app_flow/app_flow_state.dart';
import 'home_screen.dart';
import 'login_register_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const routeName = '/language';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppFlowCubit, AppFlowState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case AppFlowStatus.authentication:
            Navigator.of(
              context,
            ).pushReplacementNamed(LoginRegisterScreen.routeName);
            break;
          case AppFlowStatus.home:
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            break;
          case AppFlowStatus.languageSelection:
          case AppFlowStatus.initial:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'app_name'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.orange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'select_language'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                _LanguageButton(
                  label: 'language_english'.tr(),
                  onTap: () => _selectLanguage(context, const Locale('en')),
                ),
                const SizedBox(height: 16),
                _LanguageButton(
                  label: 'language_arabic'.tr(),
                  onTap: () => _selectLanguage(context, const Locale('ar')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectLanguage(BuildContext context, Locale locale) async {
    final messenger = ScaffoldMessenger.of(context);
    final localization = EasyLocalization.of(context);
    if (localization == null) {
      return;
    }
    final flowCubit = context.read<AppFlowCubit>();
    await localization.setLocale(locale);
    await flowCubit.saveLanguage(locale.languageCode);
    messenger.showSnackBar(
      SnackBar(content: Text('success_language_saved'.tr())),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
