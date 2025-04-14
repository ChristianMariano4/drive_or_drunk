import 'package:carousel_slider/carousel_slider.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/widgets/images/custom_rounder_image.dart';
import 'package:flutter/material.dart';

class CustomEventSlider extends StatelessWidget {
  CustomEventSlider({
    super.key,
    required this.itemsUrl,
  });

  final List<String> itemsUrl;

  final CarouselSliderController _carouselSliderController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(viewportFraction: 0.6, initialPage: 2),
              carouselController: _carouselSliderController,
              items: itemsUrl.map((url) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0), // space between items
                  child: Container(
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: CustomRoundedImage(imageUrl: url)),
                  ),
                );
              }).toList(),
            )
          ],
        ));
  }
}
