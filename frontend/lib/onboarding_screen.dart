import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

/// オンボーディング画面
/// アプリの主要機能を3-4ページで紹介
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // オンボーディングページのデータ
  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.smart_toy,
      title: 'AIが日常をサポート',
      description: '最新のAI技術で、あなたの課題を解決します',
      color: const Color(0xFF6366F1),
    ),
    OnboardingData(
      icon: Icons.phone_iphone,
      title: '直感的な操作',
      description: '写真を撮るだけ、話すだけで結果が得られます',
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingData(
      icon: Icons.track_changes,
      title: '正確な分析結果',
      description: '高度なAIアルゴリズムによる信頼性の高い結果',
      color: const Color(0xFF06B6D4),
    ),
    OnboardingData(
      icon: Icons.rocket_launch,
      title: 'さあ、始めましょう！',
      description: 'AIハッカソン2025の世界へようこそ',
      color: const Color(0xFF10B981),
    ),
  ];

  /// 次のページへ移動
  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// オンボーディングをスキップ
  void _skipOnboarding() {
    _finishOnboarding();
  }

  /// オンボーディング完了処理
  void _finishOnboarding() async {
    try {
      // 初回起動フラグを保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);

      if (!mounted) return;

      // オンボーディング完了後は必ずログイン画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // エラーの場合もログイン画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー（スキップボタン）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // 左側のスペース
                  // ページインジケーター
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 16,
                      activeDotColor: _pages[_currentIndex].color,
                      dotColor: Colors.grey.shade300,
                    ),
                  ),
                  // スキップボタン
                  if (_currentIndex < _pages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'スキップ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60), // 最後のページでは非表示
                ],
              ),
            ),

            // ページビュー
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // フッター（次へボタン）
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentIndex].color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _pages.length - 1 ? '始める' : '次へ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// オンボーディングページのデータクラス
class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// 個別のオンボーディングページウィジェット
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // アイコン
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          ),

          const SizedBox(height: 48),

          // タイトル
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // 説明文
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 80), // 下部のスペース
        ],
      ),
    );
  }
}