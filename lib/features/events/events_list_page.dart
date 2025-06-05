import 'dart:async';

import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart' show AppSizes;
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/services/firestore_service.dart'
    show FirestoreService;
import 'package:drive_or_drunk_app/widgets/custom_stream_builder.dart';
import 'package:drive_or_drunk_app/widgets/events/event_card.dart';
import 'package:flutter/material.dart';

class EventsListPage extends StatefulWidget {
  final String? eventName;
  final String? place;
  final DateTimeRange? dateRange;

  const EventsListPage({super.key, this.eventName, this.place, this.dateRange});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<List<Event>> events;

  @override
  void initState() {
    super.initState();

    if (widget.eventName != null ||
        widget.place != null ||
        widget.dateRange != null) {
      events = FirestoreService().searchEvents(
          eventName: widget.eventName,
          place: widget.place,
          dateRange: widget.dateRange);
    } else {
      events = _firestoreService.getEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              // TODO: location should be dynamic
                              Text('Milano',
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
                  // TODO: Change location using the search menu.
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
