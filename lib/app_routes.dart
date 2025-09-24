import 'package:flutter/material.dart';

import 'presentation/screens/admin/employee_add_screen.dart';
import 'presentation/screens/admin/employees_admin_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/screens/login_register_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/admin/sections_services_admin_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String language = '/lang';
  static const String auth = '/auth';
  static const String home = '/home';

  static const String adminSections = '/admin/sections';
  static const String adminEmployees = '/admin/employees';
  static const String adminWorkgroups = '/admin/workgroups';
  static const String adminGuests = '/admin/guests';
  static const String employeesAdd = '/admin/employees/add';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case language:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case auth:
        return MaterialPageRoute(builder: (_) => const LoginRegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case adminSections:
        {
          final args = settings.arguments as Map<String, dynamic>?;

          final hotelId = (args?['hotelId'] as String?) ?? '';
          return MaterialPageRoute(
            builder: (_) => SectionsServicesAdminScreen(hotelId: hotelId),
          );
        }

      case adminEmployees:
        final map = settings.arguments as Map?;
        final hotelId = (map?['hotelId'] as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => EmployeesAdminScreen(hotelId: hotelId),
          settings: settings,
        );

      case employeesAdd:
        // يدعم الإرسال كسلسلة مباشرة أو كخريطة {hotelId: ...}
        final args = settings.arguments;
        String? hotelId;
        if (args is String) {
          hotelId = args;
        } else if (args is Map) {
          final v = args['hotelId'];
          if (v is String) hotelId = v;
        }
        return MaterialPageRoute(
          builder: (_) => EmployeeAddScreen(hotelId: hotelId ?? ''),
          settings: settings,
        );
      case adminWorkgroups:
        return MaterialPageRoute(
          builder: (_) => const _StubScreen(title: 'Workgroups (soon)'),
        );
      case adminGuests:
        return MaterialPageRoute(
          builder: (_) => const _StubScreen(title: 'Guests (soon)'),
        );

      default:
        return MaterialPageRoute(builder: (_) => const _UnknownRouteScreen());
    }
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Coming soon…')),
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Unknown route')));
  }
}
