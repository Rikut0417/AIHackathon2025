import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'login.dart';
import 'search_result.dart';

/// 統一デザインによる新しいホーム画面
/// スプラッシュ・オンボーディング画面との一貫性を保つ
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  final _hobbiesController = TextEditingController();
  final _birthplaceController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  // アニメーションコントローラー
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // アニメーション初期化
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // アニメーション開始
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  /// 検索処理
  void _search() async {
    // エラーメッセージをクリア
    setState(() {
      _errorMessage = null;
    });

    // 入力値のバリデーション
    if (_hobbiesController.text.trim().isEmpty && 
        _birthplaceController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '趣味または出身地のどちらか一つは入力してください。';
      });
      return;
    }

    // ローディング開始
    setState(() {
      _isLoading = true;
    });

    // アニメーション効果のため少し待機
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // ローディング終了
    setState(() {
      _isLoading = false;
    });

    // 検索結果画面に遷移
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SearchResultScreen(
          hobbies: _hobbiesController.text.trim(),
          birthplace: _birthplaceController.text.trim(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// ログイン画面に遷移
  void _navigateToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _hobbiesController.dispose();
    _birthplaceController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              _buildHeader(),
              
              // メインコンテンツ
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        
                        // ウェルカムセクション
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildWelcomeSection(),
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 検索フォーム
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildSearchForm(),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        
                        // 機能紹介カード
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildFeatureCards(),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ヘッダー部分を構築
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ロゴ
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'ProfileAI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          
          // ログインボタン
          AppButton(
            text: 'ログイン',
            onPressed: _navigateToLogin,
            height: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
          ),
        ],
      ),
    );
  }

  /// ウェルカムセクションを構築
  Widget _buildWelcomeSection() {
    return AppGradientCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.waving_hand,
                color: AppColors.textWhite,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ようこそ、okrago10さん！',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'AIを活用したプロフィール検索で、新しい出会いを見つけましょう',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textWhite,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 検索フォームを構築
  Widget _buildSearchForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // フォームヘッダー
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search,
                  color: AppColors.primaryIndigo,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'プロフィール検索',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '趣味や出身地から人を探してみましょう\n両方入力すると、両方が一致する人を探します',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // エラーメッセージ
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: AppRadius.mediumBorder,
                border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 入力フィールド
          const Text(
            '趣味',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _hobbiesController,
            hintText: '趣味を入力してください',
            prefixIcon: Icons.interests,
          ),

          const SizedBox(height: AppSpacing.lg),

          const Text(
            '出身地',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            controller: _birthplaceController,
            hintText: '出身地を入力してください',
            prefixIcon: Icons.location_on,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 検索ボタン
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: '検索する',
              onPressed: _isLoading ? null : _search,
              isLoading: _isLoading,
              icon: Icons.search,
            ),
          ),
        ],
      ),
    );
  }

  /// 機能紹介カードを構築
  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主な機能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        Row(
          children: [
            // AI検索機能
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: AppColors.primaryIndigo,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'AI検索',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      '高度なAIアルゴリズムによる精密な検索',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // 高速検索機能
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: AppColors.accentCyan,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      '高速検索',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'リアルタイムで瞬時に結果を表示',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}