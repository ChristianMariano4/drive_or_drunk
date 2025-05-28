import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/utils/theme_utils.dart' show isThemeDark;
import 'package:flutter/material.dart';

class CircularButtonWithBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool blendedBackground;

  const CircularButtonWithBackground({
    super.key,
    required this.child,
    this.borderRadius = AppSizes.lg,
    this.blendedBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: (blendedBackground)
            ? Theme.of(context).scaffoldBackgroundColor
            : isThemeDark(context)
                ? AppColors.filledBackgroundColorDark
                : AppColors.filledBackgroundColorLight,
      ),
      child: child,
    );
  }
}
