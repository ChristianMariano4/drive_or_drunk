import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/global_keys.dart';
import 'package:drive_or_drunk_app/core/theme/app_theme.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_provider.dart';
import 'package:drive_or_drunk_app/features/authentication/auth_repository.dart';
import 'package:drive_or_drunk_app/features/authentication/firebase_auth_datasource.dart';
import 'package:drive_or_drunk_app/features/authentication/login_page.dart';
import 'package:drive_or_drunk_app/features/authentication/user_provider.dart';
import 'package:drive_or_drunk_app/firebase_options.dart';
import 'package:drive_or_drunk_app/services/api_key_service.dart';
import 'package:drive_or_drunk_app/services/google_places.dart'
    show GooglePlaces;
import 'package:drive_or_drunk_app/services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('tr');
  await initializeDateFormatting('it');

  if (dotenv.env['GOOGLE_API_KEY'] == null ||
      dotenv.env['GOOGLE_API_KEY']!.isEmpty) {
    throw Exception('GOOGLE_API_KEY is not set in .env file');
  }
  try {
    await ApiKeyService.setupApiKey();
  } catch (e) {
    debugPrint('Failed to setup API key: $e');
    // You might want to handle this error appropriately
  }
  GooglePlaces.initialize(dotenv.env['GOOGLE_API_KEY']!);

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
    try {
      UserService().init(userProvider);
    } catch (e) {
      debugPrint('Error initializing UserService: $e');
    }

    return MaterialApp(
      title: 'Drive or Drunk',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const LoginPage(),
      navigatorKey: GlobalKeys.navigatorKey,
      onGenerateRoute: AppRoutes.generateRoute,
      scaffoldMessengerKey: GlobalKeys.scaffoldMessengerKey,
    );
  }
}
