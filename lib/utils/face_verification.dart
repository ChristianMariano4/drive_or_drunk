import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<void> verifyFaces(Uint8List selfieBytes, Uint8List idBytes) async {
  final uri = Uri.parse("https://azure-faces-docker.onrender.com/verify-face");

  final request = http.MultipartRequest("POST", uri)
    ..files.add(http.MultipartFile.fromBytes('selfie', selfieBytes,
        filename: 'selfie.jpg'))
    ..files
        .add(http.MultipartFile.fromBytes('id', idBytes, filename: 'id.jpg'));

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("✅ Face Match Response: $responseBody");
    } else {
      print("❌ Face Match Error (${response.statusCode}): $responseBody");
    }
  } catch (e) {
    print("⚠️ Exception: $e");
  }
}
