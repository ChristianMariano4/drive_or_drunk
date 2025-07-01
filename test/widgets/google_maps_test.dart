import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/event_model.dart';
import 'package:drive_or_drunk_app/widgets/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('meters to lat/lng conversions', () {
    expect(metersToLatitude(111320), closeTo(1, 0.0001));
    expect(metersToLongitude(111320, 0), closeTo(1, 0.0001));
  });

  test('isLocationWithinRadius works', () {
    final location = const GeoPoint(0, 0);
    final center = const LatLng(0, 0);
    expect(isLocationWithinRadius(location, center, 1000), isTrue);
  });

  testWidgets('create marker utilities', (tester) async {
    final event = Event(
      id: '1',
      name: 'Test',
      author: '1',
      place: 'A',
      date: DateTime.now(),
      location: const GeoPoint(1, 2),
    );

    await tester.pumpWidget(const MaterialApp(home: Material()));

    final marker = createMarker(
      tester.element(find.byType(Material)),
      event: event,
    );

    expect(marker.markerId.value, '1');
    expect(marker.position.latitude, 1);
    expect(marker.position.longitude, 2);

    final markers = createMarkersFromEvents(
      tester.element(find.byType(Material)),
      [event],
    );
    expect(markers.containsKey('1'), isTrue);
  });
}
