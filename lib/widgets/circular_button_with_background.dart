import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/utils/theme_utils.dart' show isThemeDark;
import 'package:flutter/material.dart';

/// A circular customizable background color and padding.
/// 
/// [blendedBackground] will use the current theme's scaffold background color
/// 
/// if true, otherwise it will use a default color based on the theme.
/// 
/// The [backgroundColor] can be set to override the default background color.
/// If [backgroundColor] is true, the [blendedBackground] will be ignored.
/// 
/// The [borderRadius] can be adjusted to change the roundness of the button.
/// 
/// The [padding] can be adjusted to change the inner padding of the button.

class CircularButtonWithBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool blendedBackground;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const CircularButtonWithBackground({
    super.key,
    required this.child,
    this.borderRadius = AppSizes.lg,
    this.blendedBackground = false,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ??
        (blendedBackground
            ? Theme.of(context).scaffoldBackgroundColor
            : isThemeDark(context)
                ? AppColors.filledBackgroundColorDark
                : AppColors.filledBackgroundColorLight);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: background,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
