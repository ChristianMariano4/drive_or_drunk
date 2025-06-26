import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart'
    show imageProviderFromBase64;
import 'package:drive_or_drunk_app/utils/theme_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedMonth;
import 'package:drive_or_drunk_app/widgets/circular_button_with_background.dart';
import 'package:drive_or_drunk_app/widgets/clippers/banner_clipper.dart';
import 'package:flutter/material.dart';

num roundToNearestTen(num value) {
  if (value < 10) {
    return value;
  }
  if (value < 100) {
    return (value / 10).round() * 10;
  } else if (value < 1000) {
    return (value / 100).round() * 100;
  } else {
    return (value / 1000).round() * 1000;
  }
}

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});
  final Event event;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BannerShapeClipper(),
      child: Material(
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.eventDetails,
              arguments: widget.event,
            );
          },
          child: Stack(
            children: [
              // Background image
              Ink.image(
                  height: AppSizes.productImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  image: imageProviderFromBase64(
                    widget.event.image,
                    defaultImagePath: 'assets/events/event1.png',
                  )),

              // Gradient overlay
              Container(
                height: AppSizes.productImageHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (Theme.of(context)
                          .scaffoldBackgroundColor
                          .withAlpha(isThemeDark(context) ? 180 : 150)),
                      Colors.transparent
                    ],
                  ),
                ),
              ),

              // Left colored bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: AppSizes.sm * 1.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              // Text and content
              Positioned(
                left: AppSizes.md * 1.5,
                bottom: AppSizes.sm,
                child: Column(
                  spacing: AppSizes.sm,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.name,
                      style: const TextStyle(
                        fontSize: AppSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      spacing: AppSizes.sm,
                      children: [
                        Text(
                          '${roundToNearestTen(widget.event.drivers.length + widget.event.drunkards.length)}+ Participants',
                          style: const TextStyle(
                            fontSize: AppSizes.fontSizeMd,
                          ),
                        ),
                        const Icon(
                          Icons.double_arrow_rounded,
                          size: AppSizes.iconMd,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Date on the right
              Positioned(
                right: AppSizes.md * 1.5,
                top: AppSizes.md * 2.5,
                child: CircularButtonWithBackground(
                  blendedBackground: true,
                  padding: const EdgeInsets.only(
                    top: AppSizes.sm,
                    bottom: AppSizes.sm,
                    left: AppSizes.sm * 1.5,
                    right: AppSizes.sm * 1.5,
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.event.date.day.toString(),
                        style: const TextStyle(
                          fontSize: AppSizes.fontSizeXl,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        getLocalizedMonth(widget.event.date),
                        style: const TextStyle(
                          fontSize: AppSizes.fontSizeMd,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
