import 'dart:convert' show base64Decode, base64Encode;
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart'
    show
        Alignment,
        Animation,
        AssetImage,
        BoxFit,
        Image,
        ImageProvider,
        ImageRepeat,
        MemoryImage;
import 'package:path_provider/path_provider.dart';

Image imageFromBase64(String? base64String,
    {String? defaultImagePath,
    BoxFit? fit,
    double? width,
    double? height,
    Animation<double>? opacity,
    Alignment alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat}) {
  try {
    if (base64String == '') {
      return Image.asset(defaultImagePath ?? 'assets/logos/logo_android12.png',
          fit: fit,
          width: width,
          height: height,
          opacity: opacity,
          alignment: alignment,
          repeat: repeat);
    }
    final base64Data = base64String!.split(',').last;
    final Uint8List bytes = base64Decode(base64Data);
    return Image.memory(bytes,
        fit: fit,
        width: width,
        height: height,
        opacity: opacity,
        alignment: alignment,
        repeat: repeat);
  } catch (e) {
    return Image.asset(defaultImagePath ?? 'assets/logos/logo_android12.png',
        fit: fit,
        width: width,
        height: height,
        opacity: opacity,
        alignment: alignment,
        repeat: repeat);
  }
}

Uint8List bytesFromBase64(String? base64String) {
  if (base64String == null || base64String.isEmpty) {
    throw Exception('Base64 string is null or empty');
  }
  try {
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  } catch (e) {
    throw Exception('Error decoding base64 string: $e');
  }
}

Future<File> base64ToFile(String base64Str, String filename) async {
  final base64Data = base64Str.split(',').last;

  final bytes = base64Decode(base64Data);

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');

  return await file.writeAsBytes(bytes);
}

ImageProvider imageProviderFromBase64(String? base64String,
    {String? defaultImagePath}) {
  if (base64String == null || base64String.isEmpty) {
    return AssetImage(defaultImagePath ?? 'assets/logos/logo_android12.png');
  }
  try {
    final base64Data = base64String.split(',').last;
    final Uint8List bytes = base64Decode(base64Data);
    return MemoryImage(bytes);
  } catch (e) {
    return AssetImage(defaultImagePath ?? 'assets/logos/logo_android12.png');
  }
}

String base64StringFromImage(File imageFile) {
  try {
    final byteData = imageFile.readAsBytesSync();
    final Uint8List bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  } catch (e) {
    throw Exception('Error converting image to base64: $e');
  }
}
