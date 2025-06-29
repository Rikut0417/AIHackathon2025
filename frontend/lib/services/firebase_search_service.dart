import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class FirebaseSearchService {
  static String get baseUrl {
    // dart-defineまたは環境変数から取得
    // ローカル開発時は http://localhost:8080、本番時は環境変数で指定
    const url = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
    return url;
  }

  // 新しいデザインに対応したインスタンスメソッド（同義語展開情報も返す）
  Future<Map<String, dynamic>> searchProfilesWithInfo(
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
        final searchInfo = result['search_info'] as Map<String, dynamic>?;
        return {
          'users': users?.cast<Map<String, dynamic>>() ?? [],
          'search_info': searchInfo ?? {},
        };
      } else {
        throw Exception(result['error'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('検索に失敗しました: $e');
    }
  }

  // 後方互換性のために既存メソッドも残す
  Future<List<Map<String, dynamic>>> searchProfiles(
    String hobby,
    String birthplace,
  ) async {
    final result = await searchProfilesWithInfo(hobby, birthplace);
    return result['users'] as List<Map<String, dynamic>>;
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