import 'package:flutter/material.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メールアドレスとパスワードを入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // ログイン処理のシミュレーション
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ログインに成功しました'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFAFAFA),
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              margin: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: Colors.grey.shade100, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ヘッダー部分
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ログイン',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'アカウントにアクセスしてください',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // メールアドレス入力フィールド
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'メールアドレス',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'example@email.com',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // パスワード入力フィールド
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'パスワード',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'パスワードを入力してください',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF6366F1),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // パスワードを忘れた場合のリンク
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('パスワードリセット機能は実装されていません'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text("パスワードをお忘れですか？"),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ログインボタン
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading 
                              ? Colors.grey.shade300 
                              : const Color(0xFF6366F1),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.login, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'ログイン',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 区切り線
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'または',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 新規登録ボタン
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('アカウント登録機能は実装されていません'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '新規アカウント作成',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}