import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    final List<Widget> stars = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(Icons.star, color: Color(0xFF095D9E), size: 20));
      } else if (i - rating < 1) {
        stars.add(
            const Icon(Icons.star_half, color: Color(0xFF095D9E), size: 20));
      } else {
        stars.add(
            const Icon(Icons.star_border, color: Color(0xFF095D9E), size: 20));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}
