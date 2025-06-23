import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<String> sendImageToOCR(Uint8List imageBytes) async {
  final base64Image = base64Encode(imageBytes);

  final response = await http.post(
    Uri.parse('https://ocr-docker-5kq7.onrender.com/ocr'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'Image': base64Image}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['text'] ?? 'No text found';
  } else {
    throw Exception('OCR request failed: ${response.body}');
  }
}
