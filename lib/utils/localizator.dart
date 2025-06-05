import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String?> getCurrentCountryCode() async {
  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
  final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  return placemarks.first.isoCountryCode?.toUpperCase();
}
