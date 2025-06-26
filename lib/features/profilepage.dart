import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/utils/face_verification.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/utils/ocr.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/ocr_test.dart';
import 'package:drive_or_drunk_app/widgets/profile_ratingcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String owner;

  const ProfilePage({super.key, required this.owner});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirestoreService db = FirestoreService();
  user_model.User? currentUser;
  DocumentReference? ownerRef;
  late final ValueNotifier<bool> isFavorite = ValueNotifier(false);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadState();
  }

  Future<void> loadState() async {
    final user = await db.getUser(FirebaseAuth.instance.currentUser!.uid);
    final ownerRef = await db.getUserReference(widget.owner);
    setState(() {
      currentUser = user;
      this.ownerRef = ownerRef;
      isLoading = false;
    });
    isFavorite.value = currentUser!.favoriteUsers.contains(ownerRef);
  }

  void _toggleFavorite() async {
    if (isFavorite.value) {
      db.removeFavoriteUser(ownerRef!, currentUser!);
    } else {
      // Add to favorites
      db.addFavoriteUser(ownerRef!, currentUser!);
    }
    isFavorite.value = currentUser!.favoriteUsers.contains(ownerRef);
  }

  void pickImageAndSend() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    final extractedText = await sendImageToOCR(imageBytes);

    print('Extracted Text: $extractedText');
  }

  void pickTwoImagesAndVerify() async {
    final picker = ImagePicker();

    final picked1 = await picker.pickImage(source: ImageSource.gallery);
    if (picked1 == null) return;

    final picked2 = await picker.pickImage(source: ImageSource.gallery);
    if (picked2 == null) return;

    final image1Bytes = await picked1.readAsBytes();
    final image2Bytes = await picked2.readAsBytes();

    await verifyFaces(image1Bytes, image2Bytes);
  }

  @override
  Widget build(BuildContext context) {
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
        body: CustomFutureBuilder(
            future: Future.wait([db.getUser(widget.owner)]),
            component: (data) {
              final owner = data[0] as user_model.User;
              return Center(
                child: Column(
                  spacing: 10,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: FilledButton(
                        onPressed: () {
                          //TODO Add navigation functionality
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
                              backgroundImage: imageProviderFromBase64(
                                  owner.profilePicture ?? '')),
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
                                        owner.name.length <= 20
                                            ? owner.name.toUpperCase()
                                            : "${owner.name.substring(0, 18).toUpperCase()}...",
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                fontSize: 26,
                                                color: AppColors.black)),
                                    Text(owner.age.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                fontSize: 26,
                                                color: AppColors.black)),
                                  ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 40,
                                  right: owner.name.length >= 12
                                      ? 0
                                      : MediaQuery.of(context).size.width *
                                          0.15),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: isFavorite,
                                  builder: (context, value, _) {
                                    return IconButton(
                                      icon: Icon(
                                        value ? Icons.star : Icons.star_border,
                                      ),
                                      color: value
                                          ? AppColors.yellow
                                          : AppColors.yellow,
                                      iconSize: 40,
                                      onPressed: _toggleFavorite,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 40,
                                  right: owner.name.length >= 12
                                      ? 0
                                      : MediaQuery.of(context).size.width *
                                          0.15),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                      icon: const Icon(Icons.chat_rounded),
                                      iconSize: 36,
                                      color: AppColors.primaryColor,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.chatpage,
                                            arguments: {
                                              'otherUserid': owner.id
                                            });
                                      })),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: OCRTest(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.verified_user),
                                label: const Text("Verify Faces from Gallery"),
                                onPressed: pickTwoImagesAndVerify,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ProfileRatingcard(
                            owner: owner, reviewType: ReviewType.driver)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ProfileRatingcard(
                            owner: owner, reviewType: ReviewType.drunkard)),
                  ],
                ),
              );
            }));
  }
}
