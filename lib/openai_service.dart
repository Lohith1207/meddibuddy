import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/secrets.dart';

class GeminiService {
  final String _apiKey = geminiAPIKey;

  

  Future<String> sendMessage(String prompt) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
    );

    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final res = await http.post(uri, headers: headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        return 'Error ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
