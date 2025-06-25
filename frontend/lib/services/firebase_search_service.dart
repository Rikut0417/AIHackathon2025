import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseSearchService {
  static const String baseUrl = 'http://localhost:5000';

  // 新しいデザインに対応したインスタンスメソッド
  Future<List<Map<String, dynamic>>> searchProfiles(
    String hobby,
    String birthplace,
  ) async {
    try {
      final result = await searchUsers(
        hobby: hobby,
        birthplace: birthplace,
      );
      
      if (result['success'] == true) {
        final users = result['users'] as List?;
        return users?.cast<Map<String, dynamic>>() ?? [];
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('検索に失敗しました: $e');
    }
  }

  static Future<Map<String, dynamic>> searchUsers({
    required String hobby,
    required String birthplace,
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
          'birthplace': birthplace,
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