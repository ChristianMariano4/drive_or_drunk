import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/features/events/events_list_page.dart';
import 'package:drive_or_drunk_app/widgets/custom_filled_button.dart';
import 'package:drive_or_drunk_app/widgets/home_page/event_search_box.dart';
import 'package:drive_or_drunk_app/widgets/home_page/place_search_box.dart';
import 'package:flutter/material.dart';
import 'package:drive_or_drunk_app/widgets/home_page/date_picker.dart';

class EventSearchForm extends StatefulWidget {
  const EventSearchForm({super.key});

  @override
  State<EventSearchForm> createState() => _EventSearchFormState();
}

class _EventSearchFormState extends State<EventSearchForm> {
  String? eventName;
  String? place;
  DateTimeRange? dateRange;

  void _performSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsListPage(
          eventName: eventName,
          place: place,
          dateRange: dateRange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.sm),
      ),
      child: Column(
        children: [
          // Search Bar
          EventSearchBox(
            icon: Icons.search,
            labelText: "Search event name",
            hintText: "Type the name of the event",
            searchText: "Search Events",
            onChanged: (value) => setState(() => eventName = value),
          ),

          const SizedBox(height: AppSizes.spaceBtwItems),

          Row(
            children: [
              // Place & Date Filters
              Expanded(
                child: PlaceSearchBox(
                  icon: Icons.place,
                  labelText: "Select place",
                  hintText: "Type the name of a city or a club",
                  searchText: "Select Place",
                  onChanged: (value) => setState(() => place = value),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: DateRangePicker(
                  icon: Icons.calendar_today,
                  labelText: "Pick a Date",
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onChanged: (value) => setState(() => dateRange = value),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.defaultSpace),

          // Search Button
          CustomFilledButton(
            onPressed: _performSearch,
            labelText: "Search",
          ),
        ],
      ),
    );
  }
}
