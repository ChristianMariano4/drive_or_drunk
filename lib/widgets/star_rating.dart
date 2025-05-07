import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(
            const Icon(Icons.star, color: AppColors.primaryColor, size: 20));
      } else if (i - rating < 1) {
        stars.add(const Icon(Icons.star_half,
            color: AppColors.primaryColor, size: 20));
      } else {
        stars.add(const Icon(Icons.star_border,
            color: AppColors.primaryColor, size: 20));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
