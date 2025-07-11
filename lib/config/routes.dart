import 'package:drive_or_drunk_app/features/authentication/login_page.dart';
import 'package:drive_or_drunk_app/features/authentication/password_recover_page.dart';
import 'package:drive_or_drunk_app/features/authentication/register_page.dart';
import 'package:drive_or_drunk_app/features/chat/chat_page.dart';
import 'package:drive_or_drunk_app/features/events/event_detail_page.dart';
import 'package:drive_or_drunk_app/features/events/events_list_page.dart';
import 'package:drive_or_drunk_app/features/events/events_map_page.dart';
import 'package:drive_or_drunk_app/features/events/new_event_page.dart';
import 'package:drive_or_drunk_app/features/homepage.dart';
import 'package:drive_or_drunk_app/features/profile/profile_page.dart';
import 'package:drive_or_drunk_app/features/profile/review_list_page.dart';
import 'package:drive_or_drunk_app/features/users/users_list_page.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String navMenu = '/navigation';
  static const String reviewlist = '/reviewlist';
  static const String eventsList = '/eventsList';
  static const String eventsMap = '/eventsMap';
  static const String upsertEvent = '/upsertEvent';
  static const String chatpage = '/chatpage';
  static const String eventDetails = '/eventDetails';
  static const String usersList = '/usersList';
  static const String userProfile = '/userProfile';

  static const recoverPassword = '/recoverPassword';

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
              if (currentUser != null &&
                  (routeName == login || routeName == register)) {
                return const NavigationMenu();
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
        final user = settings.arguments as String;
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
      case eventsList:
        final args = settings.arguments as Map<String, dynamic>;
        final locationSearchCenter = args['locationSearchCenter'] as LatLng?;
        return authenticatedRoute(
            builder: (_) =>
                EventsListPage(locationSearchCenter: locationSearchCenter),
            routeName: eventsList);
      case eventsMap:
        return authenticatedRoute(
            builder: (_) => const EventsMapPage(), routeName: eventsMap);
      case usersList:
        final String? query = settings.arguments as String?;
        return authenticatedRoute(
            builder: (_) => UsersListPage(
                  nameQuery: query,
                ),
            routeName: usersList);
      case userProfile:
        final String userId = settings.arguments as String;
        return authenticatedRoute(
            builder: (_) => ProfilePage(owner: userId), routeName: userProfile);
      case upsertEvent:
        final event = settings.arguments as Event?;
        return authenticatedRoute(
            builder: (_) => UpsertEventPage(event: event),
            routeName: upsertEvent);
      case eventDetails:
        try {
          final event = settings.arguments as Event;
          return authenticatedRoute(
              builder: (_) => EventDetailPage(event: event),
              routeName: eventDetails);
        } on TypeError {
          throw Exception(
              'Invalid arguments for $eventDetails: ${settings.arguments}');
        }
      case recoverPassword:
        return authenticatedRoute(
            builder: (_) => const PasswordRecoverPage(),
            routeName: recoverPassword);
      case chatpage:
        final args = settings.arguments as Map<String, dynamic>;
        final id = args['otherUserid'] as String;
        return authenticatedRoute(
            builder: (_) => ChatPage(otherUserid: id), routeName: chatpage);
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
