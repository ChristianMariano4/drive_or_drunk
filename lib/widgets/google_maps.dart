import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/config/routes.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/widgets/custom_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Don't try to create empty marker!
Marker createMarker(BuildContext context,
    {LatLng? location,
    String? id,
    Event? event,
    String? title,
    String? snippet}) {
  return Marker(
    markerId: MarkerId(id ?? event!.id!),
    position: location ??
        LatLng(event!.location!.latitude, event.location!.longitude),
    infoWindow: InfoWindow(
      title: title ?? event!.name,
      snippet: snippet ?? event!.place,
      onTap: () {
        if (event != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.eventDetails,
            arguments: event,
          );
        }
      },
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  );
}

Map<String, Marker> createMarkersFromEvents(
    BuildContext context, List<Event> events) {
  final markers = <String, Marker>{};
  for (final event in events) {
    if (event.location == null) {
      continue;
    }
    markers[event.id!] = createMarker(context, event: event);
  }
  return markers;
}

double metersToLatitude(double meters) {
  return meters / 111320.0;
}

double metersToLongitude(double meters, double latitude) {
  return meters / (111320.0 * math.cos(latitude * (math.pi / 180.0)));
}

bool isLocationWithinRadius(GeoPoint location, LatLng center, double radius) {
  final mapCircleRadiusLatitude = metersToLatitude(radius);
  final mapCircleRadiusTopLongitude =
      metersToLongitude(radius, center.latitude + mapCircleRadiusLatitude);
  final mapCircleRadiusBottomLongitude =
      metersToLongitude(radius, center.latitude - mapCircleRadiusLatitude);

  final isInRight =
      (location.latitude) >= (center.latitude - mapCircleRadiusLatitude);
  final isInLeft =
      (location.latitude) <= (center.latitude + mapCircleRadiusLatitude);
  final isInTop = (location.longitude) >=
      (center.longitude - mapCircleRadiusBottomLongitude);
  final isInBottom =
      (location.longitude) <= (center.longitude + mapCircleRadiusTopLongitude);
  return isInRight && isInLeft && isInTop && isInBottom;
}

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({
    super.key,
    this.onTap,
    this.onLongPress,
    this.initialPosition = const LatLng(45.4780811773664, 9.226344041526318),
    this.markers = const {},
    this.circles = const {},
    this.onCameraMove,
  });
  final LatLng initialPosition;
  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;
  final void Function(CameraPosition)? onCameraMove;
  final Map<String, Marker> markers;
  final Set<Circle> circles;

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;
  late final Stream<List<Event>> events;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _requestLocationPermission();
  }

  Future<String> _loadMapStyle() async {
    return await rootBundle.loadString('assets/map_style.json');
  }

  Future<void> _showPermissionDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to function properly. '
            'Please enable location access in Settings. If already enabled just ignore this message.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    final permission =
        Platform.isIOS ? Permission.locationWhenInUse : Permission.location;

    var permissionStatus = await permission.status;

    if (permissionStatus.isDenied) {
      permissionStatus = await permission.request();

      if (permissionStatus.isGranted) {
        debugPrint("Location permission granted");
      } else if (permissionStatus.isDenied) {
        debugPrint("Location permission denied");
      } else if (permissionStatus.isPermanentlyDenied) {
        debugPrint("Location permission permanently denied");
        await _showPermissionDialog();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      debugPrint("Location permission permanently denied");
      await _showPermissionDialog();
    } else if (permissionStatus.isGranted) {
      debugPrint("Location permission already granted");
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: _loadMapStyle(),
      component: (mapStyle) => GoogleMap(
        style: mapStyle,
        onMapCreated: _onMapCreated,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 14.0,
        ),
        markers: widget.markers.values.toSet(),
        myLocationEnabled: true,
        circles: widget.circles,
        onCameraMove: widget.onCameraMove,
      ),
    );
  }
}
