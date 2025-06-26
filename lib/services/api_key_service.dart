import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web/web.dart' as web;

class ApiKeyService {
  static const platform = MethodChannel('google_api_key');
  static bool _isLoaded = false;
  static bool _isLoading = false;

  static Future<void> setupApiKey() async {
    if (_isLoaded) {
      return;
    }
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    _isLoading = true;

    try {
      final apiKey = dotenv.env['GOOGLE_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GOOGLE_API_KEY is not set in .env');
      }

      if (kIsWeb) {
        final existingScript =
            web.document.querySelector('script[src*="maps.googleapis.com"]');

        if (existingScript != null) {
          _isLoaded = true;
          _isLoading = false;
          return;
        }

        final script = web.HTMLScriptElement()
          ..src =
              'https://maps.googleapis.com/maps/api/js?key=$apiKey&loading=async'
          ..async = true
          ..defer = true;

        web.document.head!.append(script);
        await script.onLoad.first;
        _isLoaded = true;
        debugPrint('API key set in web/index.html successfully');
      } else if (Platform.isIOS) {
        await platform.invokeMethod('setApiKey', apiKey);
        _isLoaded = true;
        debugPrint('API key sent to iOS successfully');
      } else {
        debugPrint('API key setup not needed for this platform');
      }
    } catch (e) {
      debugPrint('Error setting up API key: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}
