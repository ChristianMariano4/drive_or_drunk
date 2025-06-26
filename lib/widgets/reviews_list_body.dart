import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/models/review_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewsListBody extends StatelessWidget {
  const ReviewsListBody({
    super.key,
    required this.db,
    required this.item,
  });

  final FirestoreService db;
  final Review item;

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: Future.wait([db.getAuthor(item)]),
      component: (data) {
        final author = data.isEmpty ? null : data[0];
        final name = author!.name;
        return Column(children: [
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Card.outlined(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        width: 1.5,
                        color: context.watch<ThemeProvider>().themeMode ==
                                ThemeMode.light
                            ? AppColors.black
                            : AppColors.white)),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: Column(spacing: 5, children: [
                    Row(
                      spacing: 30,
                      children: [
                        Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                spacing: 7,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                      radius: 15,
                                      backgroundImage: imageProviderFromBase64(
                                          author.profilePicture ?? '')),
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
                                              color: AppColors.primaryColor,
                                              fontSize: 15))
                                ]),
                            Row(
                              spacing: 15,
                              children: [
                                StarRating(
                                    rating: item.rating.toDouble(), size: 17),
                                Text(
                                    getLocalizedDateInNumberFormat(
                                        item.timestamp.toDate()),
                                    style:
                                        Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text("${item.text}\n",
                                style: Theme.of(context).textTheme.labelLarge)),
                      ],
                    ),
                  ]),
                ),
              )),
        ]);
      },
    );
  }
}
