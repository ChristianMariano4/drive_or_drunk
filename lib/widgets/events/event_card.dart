import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/utils/image_utils.dart' show imageFromBase64;
import 'package:drive_or_drunk_app/utils/theme_utils.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart'
    show getLocalizedMonth;
import 'package:drive_or_drunk_app/widgets/clippers/banner_clipper.dart';
import 'package:flutter/material.dart';

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
      child: Stack(
        children: [
          // Background image
          SizedBox(
              height: AppSizes.productImageHeight,
              width: double.infinity,
              child: imageFromBase64(
                widget.event.image,
                defaultImagePath: 'assets/events/event1.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.95),
              )),

          // Gradient overlay
          Container(
            height: AppSizes.productImageHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (Theme.of(context)
                      .scaffoldBackgroundColor
                      .withAlpha(isThemeDark(context) ? 180 : 30)),
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
            bottom: AppSizes.md,
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
                      // TODO: round the number to nearest 10/100/1000
                      '${widget.event.drivers.length + widget.event.drunkards.length}+ Participants',
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
        ],
      ),
    );
  }
}
