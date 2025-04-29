import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';
import 'package:flutter/material.dart';

class ProfileRatingcard extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final Review? review;
  final double averageRating;
  final String reviewType;

  ProfileRatingcard({
    super.key,
    required this.review,
    required this.averageRating,
    required this.reviewType,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Column(
        spacing: 5,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(reviewType.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: const Color(0xFF095D9E))),
                if (review == null) ...[
                  Row(children: [
                    Text(
                      "${averageRating.toString()} ",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: const Color(0xFF095D9E)),
                    ),
                    StarRating(rating: averageRating)
                  ]),
                ] else
                  ...[],
              ],
            ),
          ),
          const Divider(
            height: 10,
            thickness: 3,
          ),
          if (review != null) ...[
            FutureBuilder<Map<String, dynamic>?>(
              future: review?.getAuthor(db),
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
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        spacing: 5,
                        children: [
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
                                                    'profilePicture'] ==
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
                              StarRating(rating: review!.rating),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Text("${review?.text}\n",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ));
                }
              },
            ),
            // const SizedBox(
            //   height: 50,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // SizedBox(
                //     width: 100,
                //     height: 100,
                //     child:
                Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    )),
                    onPressed: null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 15,
                      children: [
                        Text("View all",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: const Color(0xFF095D9E))),
                        // const Padding(
                        //     padding: EdgeInsets.only(left: 15),
                        //     child:
                        const Icon(
                          Icons.keyboard_arrow_right,
                          color: Color(0xFF095D9E),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text("No reviews available for this user.\n",
                style: Theme.of(context).textTheme.labelLarge)
        ],
      ),
    );
  }
}
