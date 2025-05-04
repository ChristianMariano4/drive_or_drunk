import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/widgets/star_rating.dart';
import 'package:flutter/material.dart';

class ProfileRatingcard extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final user_model.User owner;
  final String reviewType;

  ProfileRatingcard({
    super.key,
    required this.owner,
    required this.reviewType,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
        child: FutureBuilder<List<Object?>>(
            future: Future.wait([
              reviewType == "driver"
                  ? owner.calculateDriverRatingAverage(db)
                  : owner.calculateDrunkardRatingAverage(db),
              reviewType == "driver"
                  ? user_model.getDriverReviews(owner, db)
                  : user_model.getDrunkardReviews(owner, db),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final data = snapshot.data ?? [];
                final avg = data.isNotEmpty && data[0] is double
                    ? data[0] as double
                    : null;
                final reviews = data.length > 1 && data[1] is List<Review>
                    ? data[1] as List<Review>
                    : null;
                return Column(spacing: 5, children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(reviewType.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: const Color(0xFF095D9E))),
                        if (reviews != null) ...[
                          Row(children: [
                            Text(
                              "${avg.toString()} ",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: const Color(0xFF095D9E)),
                            ),
                            StarRating(rating: avg!)
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
                  if (reviews != null && reviews.isNotEmpty) ...[
                    FutureBuilder<Map<String, dynamic>?>(
                      future: reviews[0].getAuthor(db),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          final data = snapshot.data ?? [];
                          final firstauthor =
                              data is Map<String, dynamic> ? data : null;

                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                                                backgroundImage: firstauthor?[
                                                            "profilePicture"] !=
                                                        null
                                                    ? NetworkImage(firstauthor?[
                                                        "profilePicture"]!)
                                                    : const AssetImage(
                                                            'assets/logos/logo_test.png')
                                                        as ImageProvider),
                                            Text(
                                                (firstauthor?["name"] as String)
                                                            .length <=
                                                        20
                                                    ? (firstauthor?["name"]
                                                            as String)
                                                        .toUpperCase()
                                                    : "${(firstauthor?["name"] as String).substring(0, 18).toUpperCase()}...",
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge
                                                    ?.copyWith(
                                                      color: const Color(
                                                          0xFF095D9E),
                                                    ))
                                          ]),
                                      StarRating(rating: reviews[0].rating),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text("${reviews[0].text}\n",
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
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/reviewlist",
                                arguments: {
                                  "reviewList": reviews,
                                  "reviewType": reviewType,
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              spacing: 15,
                              children: [
                                Text("View all",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: Colors.white)),
                                // const Padding(
                                //     padding: EdgeInsets.only(left: 15),
                                //     child:
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text("No reviews available for this user.\n",
                        style: Theme.of(context).textTheme.labelLarge)
                  ]
                ]);
              }
            }));
  }
}
