import 'package:drive_or_drunk_app/features/authentication/login_page.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:drive_or_drunk_app/features/homepage.dart';
import 'package:drive_or_drunk_app/navigation_menu.dart' show NavigationMenu;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const register = '/register';
  static const navMenu = '/navigation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Custom route wrapper that checks authentication
    MaterialPageRoute authenticatedRoute(
        {required Widget Function(BuildContext) builder,
        required String routeName}) {
      return MaterialPageRoute(
        builder: (context) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final currentUser = snapshot.data;
              // If no user is logged in and trying to access home, redirect to login
              if (currentUser == null && routeName == home) {
                return const LoginPage();
              }

              // If user is logged in and trying to access login, redirect to home
              if (currentUser != null && routeName == login) {
                return const HomePage();
              }

              // Otherwise, return the requested route
              return builder(context);
            },
          );
        },
        settings: settings,
      );
    }

    // Route generation logic
    switch (settings.name) {
      case home:
        return authenticatedRoute(
            builder: (_) => const HomePage(), routeName: home);
      case login:
        return authenticatedRoute(
            builder: (_) => const LoginPage(), routeName: login);
      case register:
        return authenticatedRoute(
            builder: (_) => const RegisterPage(), routeName: register);
      case navMenu:
        return authenticatedRoute(
            builder: (_) => const NavigationMenu(), routeName: navMenu);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
