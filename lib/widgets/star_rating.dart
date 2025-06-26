import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, required this.size});
  final double rating;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(Icon(Icons.star,
            color: AppColors.primaryColor, size: size, fill: 0.4));
      } else if (i - rating < 1) {
        stars.add(
            Icon(Icons.star_half, color: AppColors.primaryColor, size: size));
      } else {
        stars.add(
            Icon(Icons.star_border, color: AppColors.primaryColor, size: size));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
