import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/api_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'cubits/home/home_cubit.dart' as home_cubit;
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_register_screen.dart';
import 'presentation/screens/language_selection_screen.dart';

class AppRoutes {
  static const String initialRoute = '/language';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    home_cubit.HomeCubit(ApiRepository(), AuthRepository()),
              ),
            ],
            child: const HomeScreen(),
          ),
        );
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginRegisterScreen());
      case '/language':
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
