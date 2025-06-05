import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> getCitySuggestions(
    String input, String? countryCode) async {
  countryCode ??= "IT";
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$input&countrycodes=$countryCode&format=json&limit=5',
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'DriveOrDrunkApp/1.0 (christianmariano444@gmail.com)',
  });

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    // Extract and deduplicate display names
    final suggestions = <String>[];

    for (var item in data) {
      final type = item['addresstype']?.toString();
      if (type != 'village' &&
          type != 'town' &&
          type != 'city' &&
          type != 'suburb') {
        continue;
      }

      final name = item['display_name']?.toString() ?? '';
      final simplified = name.split(',').take(2).join(',').trim();

      if (simplified.isNotEmpty && !suggestions.contains(simplified)) {
        suggestions.add(simplified);
      }
    }

    return suggestions;
  } else {
    print('Failed to fetch cities: ${response.statusCode}');
    return [];
  }
}
