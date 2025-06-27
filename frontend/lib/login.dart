import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'utils/responsive_helper.dart';
import 'constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    
    // テキストフィールドの変更を監視
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }
  
  // フォームのバリデーション
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    final isValid = email.isNotEmpty && 
                   password.isNotEmpty && 
                   password.length >= 6 &&
                   _isValidEmail(email);
    
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }
  
  // メールアドレスの簡単なバリデーション
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Enterキー押下時の処理
  void _handleEnterKeyPress() {
    if (_isFormValid && !_isLoading) {
      _authenticate();
    }
  }

  void _authenticate() async {
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

    try {
      if (_isSignUp) {
        final user = await _authService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('アカウント作成に失敗しました'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ログインに失敗しました'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSignUp ? 'アカウント作成' : 'ログイン',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        // ナビゲーションスタックに前の画面がある場合のみ戻るボタンを表示
        automaticallyImplyLeading: Navigator.canPop(context),
        leading: Navigator.canPop(context) 
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: ResponsiveHelper.getIconSize(context, IconSizeType.medium),
                color: AppColors.primaryIndigo,
              ),
              onPressed: () {
                // 安全に戻る処理を実行
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // フォールバック: オンボーディング画面に戻る
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                  );
                }
              },
            )
          : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.surfaceColor,
            ],
          ),
        ),
        child: ResponsiveWrapper(
          maxWidth: ResponsiveHelper.isMobile(context) ? double.infinity : 480,
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SpacingType.lg)),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(
                ResponsiveHelper.isMobile(context) 
                  ? ResponsiveHelper.getSpacing(context, SpacingType.lg)
                  : ResponsiveHelper.getSpacing(context, SpacingType.xxl),
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.xxlargeBorder,
                border: Border.all(color: AppColors.borderLight, width: 1.0),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー部分
                  ResponsiveBuilder(
                    builder: (context, deviceType) {
                      final isCompact = deviceType == DeviceType.mobile;
                      
                      return Flex(
                        direction: isCompact ? Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                        crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              ResponsiveHelper.getSpacing(context, SpacingType.md),
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppRadius.largeBorder,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppColors.textWhite,
                              size: ResponsiveHelper.getIconSize(context, IconSizeType.large),
                            ),
                          ),
                          SizedBox(
                            width: isCompact ? 0 : ResponsiveHelper.getSpacing(context, SpacingType.lg),
                            height: isCompact ? ResponsiveHelper.getSpacing(context, SpacingType.md) : 0,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isSignUp ? 'アカウント作成' : 'ログイン',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.title),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  textAlign: isCompact ? TextAlign.center : TextAlign.left,
                                ),
                                SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.xs)),
                                Text(
                                  _isSignUp ? '新しいアカウントを作成してください' : 'アカウントにログインしてください',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                                    color: AppColors.textMedium,
                                    height: 1.4,
                                  ),
                                  textAlign: isCompact ? TextAlign.center : TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.xxl)),

                  // メールアドレス入力フィールド
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'メールアドレス',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.xs)),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'メールアドレスを入力してください',
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                            color: AppColors.textLight,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.primaryIndigo,
                            size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                          ),
                          // エラー表示
                          errorText: _emailController.text.isNotEmpty && 
                                    !_isValidEmail(_emailController.text.trim()) 
                                    ? 'メールアドレスの形式が正しくありません' 
                                    : null,
                          errorStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                            color: AppColors.errorRed,
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.errorRed),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getSpacing(context, SpacingType.md),
                            vertical: ResponsiveHelper.getSpacing(context, SpacingType.md),
                          ),
                        ),
                        onSubmitted: (_) => _handleEnterKeyPress(),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.lg)),

                  // パスワード入力フィールド
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'パスワード',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.xs)),
                          Text(
                            '*',
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                          color: AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'パスワードを入力してください',
                          hintStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                            color: AppColors.textLight,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.primaryIndigo,
                            size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.primaryIndigo,
                              size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          // パスワードの最小文字数チェック
                          errorText: _passwordController.text.isNotEmpty && 
                                    _passwordController.text.length < 6 
                                    ? 'パスワードは6文字以上で入力してください' 
                                    : null,
                          errorStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                            color: AppColors.errorRed,
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.errorRed),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mediumBorder,
                            borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getSpacing(context, SpacingType.md),
                            vertical: ResponsiveHelper.getSpacing(context, SpacingType.md),
                          ),
                        ),
                        onSubmitted: (_) => _handleEnterKeyPress(),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.md)),

                  // パスワードを忘れた場合のリンク（ログインモードのみ表示）
                  if (!_isSignUp)
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
                          foregroundColor: AppColors.primaryIndigo,
                          textStyle: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text("パスワードをお忘れですか？"),
                      ),
                    ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.xl)),

                  // ログインボタン
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.getButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isFormValid) ? null : _authenticate,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.largeBorder,
                        ),
                      ).copyWith(
                        // ホバー効果とカラー設定
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.textLight;
                            }
                            if (states.contains(WidgetState.hovered)) {
                              return AppColors.secondaryPurple;
                            }
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF5B21B6);
                            }
                            return AppColors.primaryIndigo;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return AppColors.textMedium;
                            }
                            return AppColors.textWhite;
                          },
                        ),
                        mouseCursor: WidgetStateProperty.resolveWith<MouseCursor?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return SystemMouseCursors.forbidden;
                            }
                            return SystemMouseCursors.click;
                          },
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                              height: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSignUp ? Icons.person_add : Icons.login,
                                  size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                                  color: AppColors.textWhite,
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                                Text(
                                  _isSignUp ? 'アカウント作成' : 'ログイン',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.xl)),

                  // 区切り線
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context, SpacingType.md),
                        ),
                        child: Text(
                          'または',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.lg)),

                  // 新規登録ボタン
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.getButtonHeight(context),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          // フォームをクリア
                          _emailController.clear();
                          _passwordController.clear();
                          _validateForm();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryIndigo,
                        side: const BorderSide(
                          color: AppColors.primaryIndigo,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.largeBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSignUp ? Icons.login_outlined : Icons.person_add_outlined, 
                            size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                          Text(
                            _isSignUp ? 'ログインに切り替え' : '新規アカウント作成',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
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
    );
  }

  @override
  void dispose() {
    // リスナーを削除
    _emailController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}