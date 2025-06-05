import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/home_page/custom_event_slider.dart';
import 'package:flutter/material.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  Future<List<Event>> _fetchTopTrendingEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('Event').get();

    final events = snapshot.docs.map((doc) {
      final data = doc.data();
      return Event.fromMap(data, doc.id);
    }).toList();

    // Order and take top 3
    events.sort((a, b) => (b.drivers.length + b.drunkards.length)
        .compareTo(a.drivers.length + a.drunkards.length));

    return events.where((e) => e.image!.isNotEmpty).take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder<List<Event>>(
      future: _fetchTopTrendingEvents(),
      component: (events) {
        if (events.isEmpty) {
          return const SizedBox(); // Or a placeholder widget/message
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: AppSizes.md,
                right: AppSizes.md,
                top: AppSizes.md,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Trending now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontSizeMd,
                      ),
                    ),
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
            CustomEventSlider(events: events),
          ],
        );
      },
    );
  }
}
