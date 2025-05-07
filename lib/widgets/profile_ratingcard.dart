import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/reviews_preview.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';
import 'package:flutter/material.dart';

class ProfileRatingcard extends StatelessWidget {
  final FirestoreService db = FirestoreService();
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
        child: CustomFutureBuilder(
            future: Future.wait([
              db.getAverageRating(owner, reviewType),
              db.getReviewsByType(owner, reviewType)
            ]),
            component: (data) {
              final avg = data.isNotEmpty && data[0] is double
                  ? data[0] as double
                  : null;
              final reviews = data.length > 1 && data[1] is List<Review>
                  ? data[1] as List<Review>
                  : null;
              return Column(spacing: 5, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(reviewType.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primaryColor)),
                      if (reviews != null) ...[
                        Row(children: [
                          Text(
                            "${avg.toString()} ",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.primaryColor),
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
                  color: AppColors.dividerColor,
                ),
                if (reviews != null && reviews.isNotEmpty) ...[
                  ReviewsPreview(reviews: reviews, db: db),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                              AppRoutes.reviewlist,
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
                                      ?.copyWith(color: AppColors.white)),
                              const Icon(
                                Icons.keyboard_arrow_right,
                                color: AppColors.white,
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
            }));
  }
}
