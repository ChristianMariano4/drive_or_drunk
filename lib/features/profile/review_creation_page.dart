import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class ReviewCreationPage extends StatefulWidget {
  final String authorId;
  final String receiverId;
  final String reviewType;

  const ReviewCreationPage({
    super.key,
    required this.authorId,
    required this.receiverId,
    required this.reviewType,
  });

  @override
  State<ReviewCreationPage> createState() => _ReviewCreationPageState();
}

class _ReviewCreationPageState extends State<ReviewCreationPage> {
  final TextEditingController reviewTextController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  int rating = 0;

  @override
  void initState() {
    super.initState();
  }

  void _setRating(int newRating) {
    setState(() {
      rating = newRating;
    });
  }

  void submitReview() async {
    if (reviewTextController.text.isEmpty || rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
    } else {
      final authorRef =
          await firestoreService.getUserReference(widget.authorId);
      final receiver = await firestoreService.getUser(widget.receiverId);
      final review = Review(
        author: authorRef!,
        text: reviewTextController.text,
        rating: rating,
        type: widget.reviewType,
        timestamp: Timestamp.now(),
      );
      firestoreService.addReview(review, receiver!);
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create Review"),
          actions: [
            IconButton(
                icon: const Icon(Icons.star_rate,
                    size: 30, color: AppColors.primaryColor, weight: 700),
                onPressed: submitReview),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    const Text("Rating: ", style: TextStyle(fontSize: 18)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final isFilled = index < rating;
                        return IconButton(
                          icon: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                          onPressed: () => _setRating(index + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.dividerColor,
                thickness: 1,
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      const Text("Text:", style: TextStyle(fontSize: 18)),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomTextFormField(
                            controller: reviewTextController, type: 2),
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }
}
