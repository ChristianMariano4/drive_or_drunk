import 'dart:async';

import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart' show AppSizes;
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/services/google_places.dart';
import 'package:drive_or_drunk_app/widgets/custom_dropdown.dart';
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:drive_or_drunk_app/widgets/events/event_card.dart';
import 'package:drive_or_drunk_app/widgets/home_page/tab_search_section.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsListPage extends StatefulWidget {
  final String? eventName;
  final String? place;
  final DateTimeRange? dateRange;
  final LatLng? locationSearchCenter;

  const EventsListPage(
      {super.key,
      this.eventName,
      this.place,
      this.dateRange,
      this.locationSearchCenter});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<List<Event>> events;
  String locationName = 'The World';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.eventName != null ||
        widget.place != null ||
        widget.dateRange != null ||
        widget.locationSearchCenter != null) {
      events = FirestoreService().searchEvents(
          eventName: widget.eventName,
          place: widget.place,
          dateRange: widget.dateRange,
          locationSearchCenter: widget.locationSearchCenter);
    } else {
      events = _firestoreService.getEvents();
    }
    if (widget.locationSearchCenter != null) {
      GooglePlaces.searchLocationName(location: widget.locationSearchCenter!)
          .then((value) {
        setState(() {
          locationName = value;
          isLoading = false;
        });
      }).catchError((error) {
        // Handle error if needed
      });
    } else {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
            title: Text(
          'Events',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w300),
        )),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        const TextSpan(
                            text: 'Events in ',
                            style: TextStyle(fontWeight: FontWeight.w300)),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 24,
                                  color: Theme.of(context).primaryColor),
                              Text(locationName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                iconSize: 24,
                onPressed: () {
                  CustomDropdown.show(
                      context: context,
                      child: const TabSearchSection(
                        isFromHomepage: false,
                      ));
                },
              ),
            ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            CustomStreamBuilder(
                stream: events,
                customListTileBuilder: (event) => Padding(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      child: EventCard(event: event),
                    )),
            Positioned(
              bottom: AppSizes.xl * 1.5,
              right: AppSizes.lg,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.upsertEvent);
                },
                child: const Icon(Icons.add),
              ),
            )
          ],
        ));
  }
}
