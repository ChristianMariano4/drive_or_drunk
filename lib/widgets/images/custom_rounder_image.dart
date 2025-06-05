import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart';
import 'package:flutter/material.dart';

class CustomRoundedImage extends StatelessWidget {
  const CustomRoundedImage({
    super.key,
    this.width,
    this.height,
    required this.image,
    this.applyImagesRadius = true,
    this.border,
    this.backgroundColor = AppColors.blue,
    this.fit = BoxFit.cover,
    this.padding,
    this.isNetworkImage = false,
    this.onPressed,
    this.borderRadius = AppSizes.md,
  });

  final double? width;
  final double? height;
  final String image;
  final bool applyImagesRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
              width: width,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius)),
              child: ClipRRect(
                borderRadius: applyImagesRadius
                    ? BorderRadius.circular(borderRadius)
                    : BorderRadius.zero,
                child: FittedBox(
                    fit: fit,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                        width: width,
                        height: height,
                        child: imageFromBase64(image))),
              )),
        ),
      ),
    );
  }
}
