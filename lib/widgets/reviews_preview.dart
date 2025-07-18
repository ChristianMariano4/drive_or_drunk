import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';
import 'package:flutter/material.dart';

class ReviewsPreview extends StatelessWidget {
  const ReviewsPreview({
    super.key,
    required this.reviews,
    required this.db,
  });

  final List<Review>? reviews;
  final FirestoreService db;

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: db.getAuthor(reviews![0]),
      component: (data) {
        final firstauthor = data;

        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              spacing: 5,
              children: [
                Row(
                  spacing: 30,
                  children: [
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundImage: imageProviderFromBase64(
                                    firstauthor.profilePicture ?? ''),
                              ),
                              Text(
                                  (firstauthor.name).length <= 20
                                      ? (firstauthor.name).toUpperCase()
                                      : "${(firstauthor.name).substring(0, 18).toUpperCase()}...",
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: AppColors.primaryColor,
                                          fontSize: 15))
                            ]),
                        Row(
                          spacing: 15,
                          children: [
                            StarRating(
                                rating: reviews![0].rating.toDouble(),
                                size: 17),
                            Text(
                                getLocalizedDateInNumberFormat(
                                    reviews![0].timestamp.toDate()),
                                style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text("${reviews![0].text}\n",
                            style: Theme.of(context).textTheme.labelLarge,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ));
      },
    );
  }
}
