import 'package:drive_or_drunk_app/features/authentication/login_page.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:drive_or_drunk_app/features/homepage.dart';
import 'package:drive_or_drunk_app/features/profilepage.dart';
import 'package:drive_or_drunk_app/features/reviewlistpage.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String navMenu = '/navigation';
  static const String reviewlist = '/reviewlist';

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
      case profile:
        final user = settings.arguments as user_model.User;
        return authenticatedRoute(
            builder: (_) => ProfilePage(owner: user), routeName: profile);
      case navMenu:
        return authenticatedRoute(
            builder: (_) => const NavigationMenu(), routeName: navMenu);
      case reviewlist:
        final args = settings.arguments as Map<String, dynamic>;
        final reviews = args['reviewList'] as List<Review>;
        final reviewType = args['reviewType'] as String;
        return authenticatedRoute(
            builder: (_) =>
                Reviewlistpage(reviews: reviews, reviewType: reviewType),
            routeName: reviewlist);
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
