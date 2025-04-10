import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/home_page/header_image.dart';
import 'package:drive_or_drunk_app/widgets/home_page/tab_search_section.dart';
import 'package:drive_or_drunk_app/widgets/home_page/trending_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
          IconButton(
            icon: Icon(
                context.watch<ThemeProvider>().themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${user?.email ?? 'User'}!',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Create a example user on the database
                  final db = FirebaseFirestore.instance;
                  final owner =
                      await user_model.getUser("l36ByBI030TQ58XXYmpJ", db);
                  debugPrint("Owner : ${owner?.toMap().toString()}");
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: owner,
                  );
                },
                child: const Text('Create User'),
              ),
              CustomStreamBuilder(
                stream: _firestoreService.getUsers(),
                customListTileBuilder: (user) {
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(
                        'Username: ${user.username} Registered Events: ${user.registeredEvents}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => {},
                    ),
                  );
                },
              ),
              const Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              CustomStreamBuilder(
                stream: _firestoreService.getEvents(),
                customListTileBuilder: (event) {
                  return ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                        'Drivers: ${event.drivers.length}, Drunkards: ${event.drunkards.length}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => {},
                    ),
                  );
                },
              ),
              const Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              CustomStreamBuilder(
                stream: _firestoreService.getBookings(),
                customListTileBuilder: (booking) {
                  return ListTile(
                    title: Text('Booking with event id: ${booking.eventId.id}'),
                    subtitle: Text(
                        'Driver: ${booking.driverId}, Drunkards: ${booking.drunkards.length}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => {},
                    ),
                  );
                },
              ),
              const Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              CustomStreamBuilder(
                stream: _firestoreService.getConversations(),
                customListTileBuilder: (conversation) {
                  return ListTile(
                    title: Text('Conversation with id: ${conversation.id}'),
                    subtitle: Text(
                        'Users: ${conversation.getParticipants().length}, Messages: ${conversation.messageHistory.length}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => {},
                    ),
                  );
                },
              ),
              const Divider(
                height: 40,
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              CustomStreamBuilder(
                stream: _firestoreService.getReviews(),
                customListTileBuilder: (review) {
                  return ListTile(
                      title: Text('Review with id: ${review.id}'),
                      subtitle: Text(
                          'Type: ${review.type} Comment length: ${review.comments.length} Rating: ${review.rating}'),
                      trailing: IconButton(
                          icon: const Icon(Icons.add_comment),
                          onPressed: () async {
                            // TODO: this is the wrong ID for author
                            final author = await _firestoreService
                                .getUserReference(user?.uid ?? '');
                            _firestoreService.addCommentToReview(
                                review.id!,
                                Comment.fromMap({
                                  'author': author!,
                                  'text': 'This is a comment',
                                  'rating': 5.0
                                }));
                          }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
