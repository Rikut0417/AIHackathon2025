import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    // 認証状態の永続化を確認
    _auth.setPersistence(Persistence.LOCAL);
  }

  // 認証状態の変更を監視
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      assert(() {
        debugPrint('🔍 Auth state changed: ${user?.email ?? "Not logged in"}');
        return true;
      }());
      return user;
    });
  }

  // 現在のユーザーを取得
  User? get currentUser {
    final user = _auth.currentUser;
    assert(() {
      debugPrint('👤 Current user: ${user?.email ?? "Not logged in"}');
      return true;
    }());
    return user;
  }

  // メールアドレスでサインアップ
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return null;
    }
  }

  // メールアドレスでサインイン
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }  // サインアウト
  Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        assert(() {
          debugPrint('⚠️ No user to sign out');
          return true;
        }());
        return;
      }
      
      assert(() {
        debugPrint('🚪 Signing out user: ${currentUser.email}');
        return true;
      }());
      await _auth.signOut();
      assert(() {
        debugPrint('✅ Sign out successful');
        return true;
      }());
      
      // 強制的に認証状態をリフレッシュ
      await Future.delayed(const Duration(milliseconds: 100));
      assert(() {
        debugPrint('🔄 Checking auth state after signout: ${_auth.currentUser?.email ?? "null"}');
        return true;
      }());
      
      // 追加: 認証状態の変更を強制的にトリガー
      await _auth.authStateChanges().first;
      assert(() {
        debugPrint('🔄 Auth state stream updated');
        return true;
      }());
      
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  // エラーメッセージを日本語に変換
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'このメールアドレスは登録されていません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'weak-password':
        return 'パスワードが弱すぎます';
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません';
      default:
        return '認証エラーが発生しました';
    }
  }
}
