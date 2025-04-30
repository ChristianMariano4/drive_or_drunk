import 'dart:convert' show base64Decode, base64Encode;
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart' show Image;

Image imageFromBase64(String base64String) {
  try {
    final base64Data = base64String.split(',').last;
    final Uint8List bytes = base64Decode(base64Data);
    return Image.memory(bytes);
  } catch (e) {
    return Image.asset('assets/lgoos/logo_android12.png');
  }
}

// TODO: Test this function
String base64StringFromImage(File imageFile) {
  try {
    final byteData = imageFile.readAsBytesSync();
    final Uint8List bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  } catch (e) {
    throw Exception('Error converting image to base64: $e');
  }
}
