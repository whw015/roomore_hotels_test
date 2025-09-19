import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/login_register_screen.dart';
import 'presentation/screens/splash_screen.dart';

class AppRoutes {
  static const initialRoute = SplashScreen.routeName;

  static Map<String, WidgetBuilder> buildRoutes() => {
    SplashScreen.routeName: (context) => const SplashScreen(),
    LanguageSelectionScreen.routeName: (context) =>
        const LanguageSelectionScreen(),
    LoginRegisterScreen.routeName: (context) => const LoginRegisterScreen(),
    HomeScreen.routeName: (context) => const HomeScreen(),
  };
}
