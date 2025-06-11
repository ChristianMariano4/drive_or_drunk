import 'dart:convert';
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
import 'package:drive_or_drunk_app/widgets/profile_ratingcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  void _startVerificationFlow(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Identity Verification'),
        content: const Text(
          'To verify your identity, you need to upload a picture of your driver’s license and a selfie. Please make sure both are clearly visible.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Continue'),
            onPressed: () async {
              Navigator.pop(context);

              final selfie =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              final idCard =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (selfie == null || idCard == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Both images are required')),
                );
                return;
              }

              final selfieBytes = await selfie.readAsBytes();
              final idBytes = await idCard.readAsBytes();
              final userId = FirebaseAuth.instance.currentUser?.uid;

              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not authenticated')),
                );
                return;
              }

              final uri =
                  Uri.parse('https://verify-id-dord.onrender.com/verify-id');
              final request = http.MultipartRequest('POST', uri)
                ..fields['user_id'] = userId
                ..files.add(http.MultipartFile.fromBytes(
                  'selfie',
                  selfieBytes,
                  filename: 'selfie.jpg',
                ))
                ..files.add(http.MultipartFile.fromBytes(
                  'id',
                  idBytes,
                  filename: 'id.jpg',
                ));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Verifying your identity...\nYou can continue using the app while we process.',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );

              try {
                final response = await request.send();
                final responseBody = await response.stream.bytesToString();

                if (response.statusCode == 200) {
                  final result = json.decode(responseBody);
                  final isIdentical = result['is_identical'];
                  final confidence = result['confidence'];
                  final text = result['text'];
                  final name_matched = result['name_matched'];

                  setState(() {
                    // This will rebuild the widget and conditionally hide the banner
                    isLoading = false;
                  });

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Verification Result'),
                      content: Text(
                        'Face Match: ${isIdentical ? "✅ Verified" : "❌ Not Verified"}\n'
                        'Confidence: ${(confidence * 100).toStringAsFixed(2)}%\n\n'
                        'OCR Text:$text'
                        'Name matched: $name_matched',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Error ${response.statusCode}: $responseBody'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Request failed: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  late Future<List<Object>> _profileFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.owner == currentUser!.id
              ? const Text("Your Profile")
              : const Text('Profile'),
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
                    if (!owner.isVerified)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.lightOrange,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Identity verification needed',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.black),
                                    ),
                                    Text(
                                      'Upload a driver’s license and a selfie to verify your identity.',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    _startVerificationFlow(context),
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                            if (widget.owner != (currentUser!.id ?? '')) ...[
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
                                          value
                                              ? Icons.star
                                              : Icons.star_border,
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
                              )
                            ]
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
