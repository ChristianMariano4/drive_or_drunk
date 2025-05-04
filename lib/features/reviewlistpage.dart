import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';

class Reviewlistpage extends StatelessWidget {
  final List<Review> reviews;
  final String reviewType;
  final db = FirebaseFirestore.instance;

  Reviewlistpage({super.key, required this.reviews, required this.reviewType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('${reviewType == "driver" ? "Driver" : "Drunkard"} Reviews'),
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
        body: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: reviews[index].getAuthor(db),
              builder: (context, authorSnapshot) {
                if (authorSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (authorSnapshot.hasError) {
                  return Text('Error: ${authorSnapshot.error}');
                } else {
                  final author = authorSnapshot.data;
                  final name = author != null
                      ? author["name"].toString().toUpperCase()
                      : "Unknown";
                  return Column(children: [
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Column(spacing: 5, children: [
                          Row(
                            spacing: 30,
                            children: [
                              Row(
                                  spacing: 5,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                        radius: 15,
                                        backgroundImage: author?[
                                                    'profilePicture'] !=
                                                null
                                            ? NetworkImage(
                                                author?['profilePicture'])
                                            : const AssetImage(
                                                    'assets/logos/logo_test.png')
                                                as ImageProvider),
                                    Text(
                                        name.length <= 20
                                            ? name.toUpperCase()
                                            : "${name.substring(0, 18).toUpperCase()}...",
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: const Color(0xFF095D9E),
                                            ))
                                  ]),
                              StarRating(rating: reviews[index].rating),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                "${reviews[index].text}\n",
                                style: Theme.of(context).textTheme.labelLarge,
                              )),
                            ],
                          ),
                        ])),
                    const Divider(
                      color: Color(0xFF095D9E),
                      thickness: 5,
                    )
                  ]);
                }
              },
            );
          },
        ));
  }
}
