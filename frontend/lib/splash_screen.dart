import 'package:flutter/material.dart';

/// スプラッシュ画面
/// アプリ起動時に3秒間表示し、初回起動判定を行う
class SplashScreen extends StatefulWidget {
  final bool isFirstLaunch;
  
  const SplashScreen({Key? key, this.isFirstLaunch = true}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoAnimation;
  late Animation<double> _loadingAnimation;
  
  String _loadingText = '初期化中...'; // デフォルトは初期化中

  @override
  void initState() {
    super.initState();
    
    // パラメータに基づいてローディングテキストを設定
    _loadingText = widget.isFirstLaunch ? '初期化中...' : 'ローディング中...';

    // ロゴアニメーション設定
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ローディングアニメーション設定
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // アニメーション開始
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadingController.forward();
      }
    });

    // 自動遷移を削除 - AuthWrapperに認証状態管理を任せる
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // プライマリカラー
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF8B5CF6), // Purple
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ロゴセクション
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: FadeTransition(
                      opacity: _logoAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          size: 60,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // アプリ名
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoAnimation,
                    child: const Text(
                      'Me-Too!（ミートゥー）',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // サブタイトル
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoAnimation,
                    child: const Text(
                      'みんなでつながるプロフィール検索',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // ローディングアニメーション
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _loadingAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 3,
                            value: _loadingController.isAnimating ? null : 0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _loadingText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}