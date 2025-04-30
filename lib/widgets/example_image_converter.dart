import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/utils/image_utils.dart' show imageFromBase64;
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';

final FirestoreService _firestoreService = FirestoreService();

class ExampleImageConverter extends StatefulWidget {
  const ExampleImageConverter({super.key});

  @override
  State<ExampleImageConverter> createState() => _ExampleImageConverterState();
}

class _ExampleImageConverterState extends State<ExampleImageConverter> {
  late Future<Image> _imageWidget;

  @override
  void initState() {
    super.initState();
    _imageWidget = _loadImage();
  }

  Future<Image> _loadImage() async {
    debugPrint("Auth user: ${FirebaseAuth.instance.currentUser?.uid}");
    final user =
        await _firestoreService.getUser(FirebaseAuth.instance.currentUser!.uid);
    debugPrint("pp: ${user?.profilePicture != null}");
    return imageFromBase64(user?.profilePicture ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
        future: _imageWidget,
        component: (data) {
          return Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: data.image,
                fit: BoxFit.cover,
              ),
            ),
          );
        });
  }
}
