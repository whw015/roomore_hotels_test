import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/interior_services_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/login_register_screen.dart';
import 'presentation/screens/service_item_details_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/home_repository.dart';
import 'cubits/home/home_cubit.dart';

class AppRoutes {
  static const initialRoute = SplashScreen.routeName;

  static Map<String, WidgetBuilder> buildRoutes() => {
    SplashScreen.routeName: (_) => const SplashScreen(),
    LanguageSelectionScreen.routeName: (_) => const LanguageSelectionScreen(),
    LoginRegisterScreen.routeName: (_) => const LoginRegisterScreen(),
    HomeScreen.routeName: (context) => BlocProvider(
      create: (_) => HomeCubit(
        authRepository: context.read<AuthRepository>(),
        homeRepository: context.read<HomeRepository>(),
      ),
      child: const HomeScreen(),
    ),

    InteriorServicesScreen.routeName: (_) => const InteriorServicesScreen(),
    ServiceItemDetailsScreen.routeName: (_) => const ServiceItemDetailsScreen(),
  };
}
