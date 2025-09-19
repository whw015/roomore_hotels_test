import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_routes.dart';
import 'cubits/app_flow/app_flow_cubit.dart';
import 'cubits/services_admin/services_admin_cubit.dart';
import 'data/repositories/admin_services_repository.dart';
import 'data/repositories/app_preferences_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/home_repository.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AppPreferencesRepository()),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => HomeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppFlowCubit(
              context.read<AppPreferencesRepository>(),
              context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ServicesAdminCubit(AdminServicesRepository()),
          ),
        ],
        child: MaterialApp(
          title: 'RooMore',
          theme: buildLightTheme(),
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routes: AppRoutes.buildRoutes(),
          initialRoute: AppRoutes.initialRoute,
        ),
      ),
    );
  }
}
