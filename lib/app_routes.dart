import 'package:flutter/material.dart';

import 'package:roomore_hotels_test/presentation/screens/admin/employee_add_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/admin/employee_details_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/admin/employees_admin_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/splash_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/language_selection_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/login_register_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/home_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/admin/sections_services_admin_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/interior_services_screen.dart';
import 'package:roomore_hotels_test/presentation/screens/service_item_details_screen.dart';

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

      case InteriorServicesScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const InteriorServicesScreen(),
          settings: settings,
        );

      case ServiceItemDetailsScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ServiceItemDetailsScreen(),
          settings: settings,
        );

      case adminSections:
        final argsA = settings.arguments as Map<String, dynamic>?;
        final hotelIdA = (argsA?['hotelId'] as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => SectionsServicesAdminScreen(hotelId: hotelIdA),
        );

      case adminEmployees:
        final argsB = settings.arguments as Map<String, dynamic>?;
        final hotelIdB = (argsB?['hotelId'] as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => EmployeesAdminScreen(hotelId: hotelIdB),
          settings: settings,
        );

      case employeesAdd:
        final argsC = settings.arguments as Map<String, dynamic>?;
        final hotelIdC = (argsC?['hotelId'] as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => EmployeeAddScreen(hotelId: hotelIdC),
          settings: settings,
        );

      case EmployeeDetailsScreen.routeName:
        final argsD = settings.arguments as Map<String, dynamic>?;
        final employee = argsD?['employee'];
        return MaterialPageRoute(
          builder: (_) => EmployeeDetailsScreen(employee: employee),
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
      body: const Center(child: Text('Coming soon�')),
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
