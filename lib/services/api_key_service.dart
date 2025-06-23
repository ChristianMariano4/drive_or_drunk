import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyService {
  static const platform = MethodChannel('google_api_key');

  static Future<void> setupApiKey() async {
    try {
      // Send the API key to iOS
      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        await platform.invokeMethod('setApiKey', apiKey);
        debugPrint('API key sent to iOS successfully');
      } else {
        throw Exception('GOOGLE_API_KEY not found in .env file');
      }
    } catch (e) {
      debugPrint('Error setting up API key: $e');
      rethrow;
    }
  }
}
