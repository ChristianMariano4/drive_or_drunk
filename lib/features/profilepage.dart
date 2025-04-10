import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/user_model.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final User owner;

  ProfilePage({super.key, required this.owner});

  @override
  Widget build(BuildContext context) {
    //final ImageProvider image =
    //NetworkImage(owner.profilePicture ?? 'https://via.placeholder.com/150');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // Add any additional functionality
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Object?>>(
        future: Future.wait([
          owner.getFirstDriverReview(db),
          owner.getFirstDrunkardReview(db),
          owner.calculateDriverRatingAverage(db),
          owner.calculateDrunkardRatingAverage(db)
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data ?? [];
            final firstDriver =
                data.isNotEmpty && data[0] is Review ? data[0] as Review : null;
            final firstDrunkard =
                data.length > 1 && data[1] is Review ? data[1] as Review : null;
            final averageDriverRating =
                data.length > 2 && data[2] is double ? data[2] as double : 0.0;
            final averageDrunkardRating =
                data.length > 3 && data[3] is double ? data[3] as double : 0.0;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Image(image: image),
                  Text('${owner.name} \n Age: ${owner.age}'),
                  ElevatedButton(
                    onPressed: () {
                      //Add navigation functionality
                    },
                    child: const Row(
                      children: [
                        Text("Available Rides"),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("Driver Reviews"),
                            Text(
                                "Average rating : ${averageDriverRating.toString()}/5.0"),
                          ],
                        ),
                        if (firstDriver != null)
                          FutureBuilder<Map<String, dynamic>?>(
                            future: firstDriver.getAuthor(db),
                            builder: (context, authorSnapshot) {
                              if (authorSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (authorSnapshot.hasError) {
                                return Text('Error: ${authorSnapshot.error}');
                              } else {
                                final author = authorSnapshot.data;
                                return Text(
                                    '/n${author?["name"] ?? "Unknown"} \n Rating: ${firstDriver.rating}/5.0 \n\n ${firstDriver.text}');
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text("Drunkard Reviews"),
                            Text(
                                "Average rating : ${averageDrunkardRating.toString()}/5.0"),
                          ],
                        ),
                        if (firstDrunkard != null)
                          FutureBuilder<Map<String, dynamic>?>(
                            future: firstDrunkard.getAuthor(db),
                            builder: (context, authorSnapshot) {
                              if (authorSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (authorSnapshot.hasError) {
                                return Text('Error: ${authorSnapshot.error}');
                              } else {
                                final author = authorSnapshot.data;
                                return Text(
                                    '\n${author?["name"] ?? "Unknown"} \n Rating: ${firstDrunkard.rating}/5.0 \n\n ${firstDrunkard.text}');
                              }
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
