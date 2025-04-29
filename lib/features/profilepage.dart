import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/widgets/profile_ratingcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final user_model.User owner;

  ProfilePage({super.key, required this.owner});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final ImageProvider image =
    //NetworkImage(widget.owner.profilePicture ?? 'https://via.placeholder.com/150');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
      body: FutureBuilder<List<Object?>>(
        future: Future.wait([
          widget.owner.getFirstDriverReview(widget.db),
          widget.owner.getFirstDrunkardReview(widget.db),
          widget.owner.calculateDriverRatingAverage(widget.db),
          widget.owner.calculateDrunkardRatingAverage(widget.db)
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
                spacing: 10,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: FilledButton.tonal(
                      onPressed: () {
                        // Add navigation functionality
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 5,
                          children: [
                            Text("Available Rides",
                                style: TextStyle(fontSize: 20)),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 60,
                            backgroundImage: widget.owner.profilePicture == null
                                ? NetworkImage(widget.owner.profilePicture!)
                                : const AssetImage('assets/logos/logo_test.png')
                                    as ImageProvider),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      widget.owner.name.length <= 20
                                          ? widget.owner.name.toUpperCase()
                                          : "${widget.owner.name.substring(0, 18).toUpperCase()}...",
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(fontSize: 26)),
                                  Text(widget.owner.age.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(fontSize: 26))
                                ]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 40,
                                right: widget.owner.name.length >= 12
                                    ? 0
                                    : MediaQuery.of(context).size.width * 0.15),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  icon: Icon(_isFavorite
                                      ? Icons.star
                                      : Icons.star_border),
                                  color:
                                      _isFavorite ? Colors.amber : Colors.grey,
                                  iconSize: 40,
                                  onPressed: _toggleFavorite),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 40,
                                right: widget.owner.name.length >= 12
                                    ? 0
                                    : MediaQuery.of(context).size.width * 0.15),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  icon: const Icon(Icons.chat_rounded),
                                  iconSize: 36,
                                  onPressed: () => {}),
                            ),
                          )
                        ],
                      ),
                      // Text(widget.owner.age.toString(),
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .labelLarge
                      //         ?.copyWith(fontSize: 26)),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ProfileRatingcard(
                          review: firstDriver,
                          averageRating: averageDriverRating,
                          reviewType: ReviewType.driver)),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ProfileRatingcard(
                          review: firstDrunkard,
                          averageRating: averageDrunkardRating,
                          reviewType: ReviewType.drunkard)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
