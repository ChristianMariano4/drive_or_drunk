import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/image_strings.dart';
import 'package:drive_or_drunk_app/widgets/home_page/custom_event_slider.dart';
import 'package:flutter/material.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(
              left: AppSizes.md, right: AppSizes.md, top: AppSizes.md),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Trending now",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontSizeMd)),
              ),
              Padding(
                padding: EdgeInsets.only(top: AppSizes.sm),
                child: Divider(
                  height: AppSizes.dividerHeight,
                  color: AppColors.dividerColor,
                ),
              ),
            ],
          ),
        ),
        CustomEventSlider(
          itemsUrl: const [
            Images.event1Img,
            Images.event2Img,
            Images.event3Img,
          ],
        ),
      ],
    );
  }
}
