import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/curved_clipper.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart' show Comment;
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_circular_container.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart'
    show CustomStreamBuilder;
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/home_page/custom_event_slider.dart';
import 'package:drive_or_drunk_app/widgets/images/custom_rounder_image.dart';
import 'package:drive_or_drunk_app/widgets/search_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:carousel_slider/carousel_slider.dart';

final FirestoreService _firestoreService = FirestoreService();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: user id hould be same with the database id
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipPath(
                clipper: CurvedClipper(),
                child: const Stack(children: [
                  Image(
                    image: AssetImage(Images.homepageImg),
                  ),
                  Positioned(
                      top: 10,
                      right: 20,
                      child: Text(
                        'Driver or Drunker?',
                        style: TextStyle(
                            fontSize: 24,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ]),
              ),
              const Padding(
                  padding: EdgeInsets.only(
                    left: AppSizes.md,
                    right: AppSizes.md,
                    top: AppSizes.md,
                  ),
                  child: Column(children: [
                    SearchForm(),
                    SizedBox(
                      height: AppSizes.defaultSpace,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Trending now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.fontSizeMd)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: AppSizes.sm),
                      child: Divider(
                        height: AppSizes.dividerHeight,
                      ),
                    ),
                  ])),
              CustomEventSlider(
                itemsUrl: const [
                  Images.event1Img,
                  Images.event2Img,
                  Images.event3Img,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
