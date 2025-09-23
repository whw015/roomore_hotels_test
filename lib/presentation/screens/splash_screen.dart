import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/app_colors.dart';
import '../../cubits/app_flow/app_flow_cubit.dart';
import '../../cubits/app_flow/app_flow_state.dart';
import 'home_screen.dart';
import 'language_selection_screen.dart';
import 'login_register_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<AppFlowState>? _subscription;

  @override
  void initState() {
    super.initState();
    context.read<AppFlowCubit>().refreshFlow();
    _scheduleNavigation();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _scheduleNavigation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final cubit = context.read<AppFlowCubit>();
      final currentState = cubit.state;
      if (!currentState.isLoading &&
          currentState.status != AppFlowStatus.initial) {
        _navigateToStatus(currentState.status);
      } else {
        _subscription = cubit.stream.listen((state) {
          if (!mounted || state.isLoading) {
            return;
          }
          _subscription?.cancel();
          _navigateToStatus(state.status);
        });
      }
    });
  }

  void _navigateToStatus(AppFlowStatus status) {
    final route = _routeForStatus(status);
    Navigator.of(context).pushReplacementNamed(route);
  }

  String _routeForStatus(AppFlowStatus status) {
    switch (status) {
      case AppFlowStatus.languageSelection:
        return LanguageSelectionScreen.routeName;
      case AppFlowStatus.authentication:
        return LoginRegisterScreen.routeName;
      case AppFlowStatus.home:
        return HomeScreen.routeName;
      case AppFlowStatus.initial:
        return LanguageSelectionScreen.routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'RooMore',
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 10),
            const Text(
              'Hotels Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
