import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:drive_or_drunk_app/widgets/reviews_list_body.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Reviewlistpage extends StatelessWidget {
  final List<Review> reviews;
  final String reviewType;
  final db = FirestoreService();

  Reviewlistpage({super.key, required this.reviews, required this.reviewType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${reviewType == ReviewType.driver ? "Driver" : "Drunkard"} Reviews'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
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
        body: CustomStreamBuilder(
            stream: Stream.fromIterable([reviews]),
            customListTileBuilder: (item) {
              return ReviewsListBody(db: db, item: item);
            }));
  }
}
