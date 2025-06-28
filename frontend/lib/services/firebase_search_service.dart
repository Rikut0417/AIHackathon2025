import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class FirebaseSearchService {
  static String get baseUrl {
    // dart-defineまたは環境変数から取得
    const url = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://flask-backend-156065435185.us-central1.run.app');
    return url;
  }

  // 新しいデザインに対応したインスタンスメソッド
  Future<List<Map<String, dynamic>>> searchProfiles(
    String hobby,
    String birthplace,
  ) async {
    try {
      // 少なくとも一つは入力されている必要がある
      final trimmedHobby = hobby.trim();
      final trimmedBirthplace = birthplace.trim();
      
      if (trimmedHobby.isEmpty && trimmedBirthplace.isEmpty) {
        throw Exception('趣味または出身地のいずれかを入力してください');
      }
      
      final result = await searchUsers(
        hobby: trimmedHobby,
        birthplace: trimmedBirthplace,
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
      
      // 空の文字列もそのまま送信（バックエンドで処理）
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

  // しおりダウンロード機能
  static Future<bool> downloadBooklet({
    required String hobby,
    required String birthplace,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/generate-booklet');
      
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
        // ブラウザでダウンロードを開始
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'サークル活動しおり_${hobby.isNotEmpty ? hobby : birthplace}.txt')
          ..click();
        html.Url.revokeObjectUrl(url);
        return true;
      } else {
        print('しおりダウンロードエラー: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('しおりダウンロードエラー: $e');
      return false;
    }
  }
}