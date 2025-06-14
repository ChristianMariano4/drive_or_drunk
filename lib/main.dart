import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/theme/app_theme.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_repository.dart';
import 'package:drive_or_drunk_app/features/authentication/firebase_auth_datasource.dart';
import 'package:drive_or_drunk_app/features/authentication/user_provider.dart';
import 'package:drive_or_drunk_app/firebase_options.dart';
import 'package:drive_or_drunk_app/navigation_menu.dart';
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('tr');
  await initializeDateFormatting('it');

  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(
      const Duration(seconds: 1)); // TODO: check this crafted delay

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(FirebaseAuthDataSource()),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserService().init(userProvider);

    return MaterialApp(
      title: 'Drive or Drunk',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const NavigationMenu(),
      navigatorKey: navigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
