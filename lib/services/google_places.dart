import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlaceDisplayName {
  final String text;
  final String? languageCode;

  PlaceDisplayName({required this.text, this.languageCode});

  factory PlaceDisplayName.fromJson(Map<String, dynamic> json) {
    return PlaceDisplayName(
      text: json['text'] ?? '',
      languageCode: json['languageCode'],
    );
  }
}

class Place {
  final String? id;
  final String? name;
  final PlaceDisplayName? displayName;
  final String? formattedAddress;
  final LatLng? location;
  final double? rating;
  final int? userRatingCount;
  final List<String>? types;
  final String? nationalPhoneNumber;
  final String? websiteUri;

  Place({
    this.id,
    this.name,
    this.displayName,
    this.formattedAddress,
    this.location,
    this.rating,
    this.userRatingCount,
    this.types,
    this.nationalPhoneNumber,
    this.websiteUri,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'] != null
          ? PlaceDisplayName.fromJson(json['displayName'])
          : null,
      formattedAddress: json['formattedAddress'],
      location: json['location'] != null
          ? LatLng(
              json['location']['latitude']?.toDouble() ?? 0.0,
              json['location']['longitude']?.toDouble() ?? 0.0,
            )
          : null,
      rating: json['rating']?.toDouble(),
      userRatingCount: json['userRatingCount']?.toInt(),
      types: json['types']?.cast<String>(),
      nationalPhoneNumber: json['nationalPhoneNumber'],
      websiteUri: json['websiteUri'],
    );
  }
}

class PlacesSearchResponse {
  final List<Place> places;

  PlacesSearchResponse({required this.places});

  factory PlacesSearchResponse.fromJson(Map<String, dynamic> json) {
    return PlacesSearchResponse(
      places: (json['places'] as List<dynamic>?)
              ?.map((place) => Place.fromJson(place))
              .toList() ??
          [],
    );
  }
}

class GooglePlacesException implements Exception {
  final String message;
  final int? statusCode;

  GooglePlacesException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'PlacesException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class GooglePlaces {
  static const String _baseUrl = 'https://places.googleapis.com/v1/places';
  static String? _apiKey;
  static final http.Client _client = http.Client();

  // Initialize with API key
  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  // Default field mask for basic place information
  static const String _defaultFieldMask =
      'places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.types';

  static Future<PlacesSearchResponse> _postRequest(
    String uri,
    String? fieldMask,
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey!,
          'X-Goog-FieldMask': fieldMask ?? _defaultFieldMask,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // debugPrint('Response: ${response.body}');
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PlacesSearchResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw GooglePlacesException(
          errorData['error']?['message'] ?? 'Unknown error occurred',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is GooglePlacesException) rethrow;
      throw GooglePlacesException('Network error: ${e.toString()}');
    }
  }

  /// Search for places by text query
  /// /// [textQuery] - The text to search for (e.g., 'restaurant in Paris')
  /// /// [includedTypes] - List of place types to include (e.g., ['restaurant', 'cafe'])
  /// /// [fieldMask] - Fields to return (optional, uses default if not provided)
  /// /// [languageCode] - Language for results (e.g., 'en', 'es')
  /// Returns a [PlacesSearchResponse] containing a list of matching places
  /// Throws [GooglePlacesException] on error
  static Future<PlacesSearchResponse> searchText({
    required String textQuery,
    List<String>? includedTypes,
    String? fieldMask,
    String? languageCode,
  }) {
    _validateApiKey();
    _validateTextQuery(textQuery);

    final Map<String, dynamic> requestBody = {
      'textQuery': textQuery,
    };

    if (includedTypes != null && includedTypes.isNotEmpty) {
      requestBody['includedTypes'] = includedTypes;
    }

    if (languageCode != null) {
      requestBody['languageCode'] = languageCode;
    }

    return _postRequest(
      '$_baseUrl:searchText',
      fieldMask,
      requestBody,
    );
  }

  /// Search for nearby places
  ///
  /// [location] - The center point for the search
  /// [radius] - Search radius in meters (max 50000)
  /// [includedTypes] - List of place types to include (e.g., ['restaurant', 'cafe'])
  /// [maxResultCount] - Maximum number of results (1-20, default 10)
  /// [fieldMask] - Fields to return (optional, uses default if not provided)
  /// [languageCode] - Language for results (e.g., 'en', 'es')
  /// Returns a [PlacesSearchResponse] containing a list of nearby places
  /// Throws [GooglePlacesException] on error
  static Future<PlacesSearchResponse> searchNearby({
    required LatLng location,
    required double radius,
    List<String>? includedTypes,
    String? fieldMask,
    String? languageCode,
  }) async {
    _validateApiKey();
    _validateRadius(radius);

    final Map<String, dynamic> requestBody = {
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
          'radius': radius,
        }
      },
    };

    if (includedTypes != null && includedTypes.isNotEmpty) {
      requestBody['includedTypes'] = includedTypes;
    }

    if (languageCode != null) {
      requestBody['languageCode'] = languageCode;
    }

    return _postRequest(
      '$_baseUrl:searchNearby',
      fieldMask ?? _defaultFieldMask,
      requestBody,
    );
  }

  /// Search the name of the location
  /// [location] - The center point for the search
  /// [radius] - Search radius in meters (max 50000)
  /// Returns a String containing the name of the location
  /// Throws [GooglePlacesException] on error
  static Future<String> searchLocationName({
    required LatLng location,
    double radius = 100,
  }) async {
    final value = await searchNearby(location: location, radius: radius);
    final locationStringSplitted =
          value.places.first.formattedAddress?.split(',') ?? [];
      return locationStringSplitted[locationStringSplitted.length - 2]
          .replaceAll(RegExp(r'\d+'), '')
          .trim();
  }

  /// Search for places by text query (convenience method)
  static Future<PlacesSearchResponse> searchByText({
    required String textQuery,
    List<String>? includedTypes,
    String? fieldMask,
    String? languageCode,
  }) {
    return searchText(
      textQuery: textQuery,
      includedTypes: includedTypes,
      fieldMask: fieldMask,
      languageCode: languageCode,
    );
  }

  /// Search for restaurants nearby (convenience method)
  static Future<PlacesSearchResponse> searchNearbyRestaurants({
    required LatLng location,
    required double radius,
    int maxResultCount = 10,
    String? languageCode,
  }) {
    return searchNearby(
      location: location,
      radius: radius,
      includedTypes: ['restaurant'],
      languageCode: languageCode,
    );
  }

  // Validation methods
  static void _validateApiKey() {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw GooglePlacesException(
          'API key not initialized. Call Places.initialize(apiKey) first.');
    }
  }

  static void _validateRadius(double radius) {
    if (radius <= 0 || radius > 50000) {
      throw GooglePlacesException('Radius must be between 1 and 50000 meters.');
    }
  }

  static void _validateTextQuery(String textQuery) {
    if (textQuery.isEmpty) {
      throw GooglePlacesException('Text query cannot be empty.');
    }
  }

  // Dispose method to clean up resources
  static void dispose() {
    _client.close();
  }
}
