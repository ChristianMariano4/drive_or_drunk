import 'package:drive_or_drunk_app/config/routes.dart' show AppRoutes;
import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/constants/constants.dart'
    show mapCircleRadius;
import 'package:drive_or_drunk_app/services/firestore_service.dart';
import 'package:drive_or_drunk_app/services/google_places.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:drive_or_drunk_app/widgets/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show Circle, CircleId, LatLng;

class EventsMapPage extends StatefulWidget {
  const EventsMapPage({super.key});

  @override
  State<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  final FirestoreService _firestoreService = FirestoreService();

  late final ValueNotifier<bool> newLocation = ValueNotifier(false);
  Circle? circle;

  final TextEditingController _searchController = TextEditingController();

  void submitSearchText() async {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search text first')),
      );
      return;
    }
    try {
      final textResponse =
          await GooglePlaces.searchByText(textQuery: _searchController.text);
      if (textResponse.places.isNotEmpty) {
        final place = textResponse.places.first;
        if (place.location == null) {
          debugPrint('Place location is null');
          return;
        }
        if (place.location == circle?.center) {
          return;
        }
        circle = Circle(
          circleId: const CircleId('circle'),
          fillColor: AppColors.primaryColor.withAlpha(100),
          strokeColor: AppColors.primaryColor,
          strokeWidth: 1,
          center: place.location!,
          radius: mapCircleRadius,
        );
        newLocation.value = !newLocation.value;
      } else {
        debugPrint('No places found by text query');
      }
    } catch (e) {
      debugPrint('Error searching by text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Events Map'),
          elevation: 2,
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.52,
              height: AppSizes.appBarHeight * 0.7,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search area by text',
                  suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        circle = null;
                        newLocation.value = !newLocation.value;
                      },
                      icon: const Icon(Icons.clear_rounded)),
                  border: const OutlineInputBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(AppSizes.sm)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                ),
                onSubmitted: (value) async {
                  submitSearchText();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: submitSearchText,
            )
          ],
        ),
        body: CustomFutureBuilder(
          future: _firestoreService
              .getEvents()
              .first, // TODO: Doesnt update value when changed
          component: (events) {
            return Stack(children: [
              ValueListenableBuilder(
                  valueListenable: newLocation,
                  builder: (context, value, _) {
                    return GoogleMaps(
                      markers: createMarkersFromEvents(context, events),
                      circles: circle != null ? {circle!} : {},
                      initialPosition: circle?.center ??
                          const LatLng(45.4780811773664, 9.226344041526318),
                      onLongPress: (position) async {
                        circle = Circle(
                            circleId: const CircleId('circle'),
                            fillColor: AppColors.primaryColor.withAlpha(100),
                            strokeColor: AppColors.primaryColor,
                            center: position,
                            radius: mapCircleRadius,
                            strokeWidth: 1);
                        newLocation.value = !newLocation.value;
                        _searchController.text =
                            await GooglePlaces.searchLocationName(
                                location: position);
                      },
                    );
                  }),
              Positioned(
                top: AppSizes.appBarHeight,
                right: AppSizes.sm,
                child: FloatingActionButton(
                  mini: true,
                  child: const Icon(Icons.list_rounded),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {}
                    Navigator.pushNamed(
                      context,
                      AppRoutes.eventsList,
                      arguments: {'locationSearchCenter': circle?.center},
                    );
                  },
                ),
              ),
            ]);
          },
        ));
  }
}
