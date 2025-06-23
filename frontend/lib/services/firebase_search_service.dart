import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseSearchService {
  static const String baseUrl = 'http://localhost:5000';

  static Future<Map<String, dynamic>> searchUsers({
    required String hobby,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/search');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'hobby': hobby,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'HTTPエラー: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'ネットワークエラー: $e',
      };
    }
  }
}