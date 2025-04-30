import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:drive_or_drunk_app/core/theme/curved_clipper.dart';
import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedClipper(),
      child: Stack(children: [
        Image.asset(
          Images.homepageImg,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const Positioned(
            top: 10,
            right: 20,
            child: Text(
              'Driver or Drunker?',
              style: TextStyle(
                  fontSize: AppSizes.fontSizeXl,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold),
            )),
      ]),
    );
  }
}
