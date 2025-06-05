import 'package:carousel_slider/carousel_slider.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/widgets/images/custom_rounder_image.dart';
import 'package:flutter/material.dart';

class CustomEventSlider extends StatelessWidget {
  final List<Event> events;

  CustomEventSlider({
    super.key,
    required this.events,
  });

  final CarouselSliderController _carouselSliderController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(viewportFraction: 0.5, initialPage: 2),
            carouselController: _carouselSliderController,
            items: events.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4.0), // space between items
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eventDetails,
                      arguments: event,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: CustomRoundedImage(
                      image: event.image!,
                      height: 200,
                    )),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
