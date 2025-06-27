import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'widgets/highlight_text.dart';
import 'services/firebase_search_service.dart';
import 'utils/responsive_helper.dart';

/// 統一デザインによる新しい検索結果画面
/// スプラッシュ・オンボーディング・ホーム画面との一貫性を保つ
class SearchResultScreen extends StatefulWidget {
  final String hobbies;
  final String birthplace;

  const SearchResultScreen({
    Key? key,
    required this.hobbies,
    required this.birthplace,
  }) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  late ScrollController _scrollController;

  // アニメーションコントローラー
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // ScrollController初期化
    _scrollController = ScrollController();

    // アニメーション初期化
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // 検索実行
    _performSearch();
  }

  /// 検索処理を実行
  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = FirebaseSearchService();
      final results = await service.searchProfiles(
        widget.hobbies,
        widget.birthplace,
      );

      await Future.delayed(const Duration(milliseconds: 500)); // UX向上のための待機

      setState(() {
        _searchResults = results.map((result) => <String, String>{
          'name': result['name']?.toString() ?? '名前なし',
          'hobby': _processHobbyData(result['hobby']),
          'birthplace': result['birthplace']?.toString() ?? '不明',
          'department': result['department']?.toString() ?? '部署不明',
          'matched_hobby': result['matched_hobby']?.toString() ?? '',
          'matched_birthplace': result['matched_birthplace']?.toString() ?? '',
        }).toList();
        _isLoading = false;
      });

      // アニメーション開始
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _slideController.forward();
      });

    } catch (e) {
      setState(() {
        _errorMessage = '検索中にエラーが発生しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 趣味データを適切に処理するヘルパー関数
  String _processHobbyData(dynamic hobby) {
    if (hobby == null) return '不明';
    
    if (hobby is List) {
      return hobby.join(', ');
    } else if (hobby is String) {
      String hobbyStr = hobby.trim();
      if (hobbyStr.startsWith('[') && hobbyStr.endsWith(']')) {
        hobbyStr = hobbyStr.substring(1, hobbyStr.length - 1);
        return hobbyStr.split(',').map((e) => e.trim()).join(', ');
      }
      return hobbyStr;
    }
    
    return hobby.toString();
  }

  /// 検索条件のサマリーテキストを生成
  String _getSearchSummary() {
    if (widget.hobbies.isNotEmpty && widget.birthplace.isNotEmpty) {
      return '趣味「${widget.hobbies}」かつ出身地「${widget.birthplace}」';
    } else if (widget.hobbies.isNotEmpty) {
      return '趣味「${widget.hobbies}」';
    } else if (widget.birthplace.isNotEmpty) {
      return '出身地「${widget.birthplace}」';
    }
    return '検索条件なし';
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          child: ResponsiveWrapper(
            child: Column(
              children: [
                // ヘッダー
                _buildHeader(),
                
                // メインコンテンツ
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _errorMessage != null
                          ? _buildErrorState()
                          : _buildResultsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ヘッダー部分を構築
  Widget _buildHeader() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final headerPadding = ResponsiveHelper.getSpacing(context, SpacingType.lg);
        final titleFontSize = ResponsiveHelper.getFontSize(context, FontSizeType.subtitle);
        final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.medium);
        final searchIconSize = ResponsiveHelper.getIconSize(context, IconSizeType.small);
        
        return Container(
          padding: EdgeInsets.all(headerPadding),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              // ナビゲーション
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textDark,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                  Expanded(
                    child: Text(
                      '検索結果',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.md)),
              
              // 検索条件サマリー
              AppCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SpacingType.md)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search,
                        color: AppColors.primaryIndigo,
                        size: searchIconSize,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.md)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '検索条件',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getSearchSummary(),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.body),
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ローディング状態を構築
  Widget _buildLoadingState() {
    return const Center(
      child: AppLoading(
        message: '検索中...',
        size: 50,
      ),
    );
  }

  /// エラー状態を構築
  Widget _buildErrorState() {
    return AppError(
      message: _errorMessage!,
      buttonText: '再試行',
      onRetry: _performSearch,
      icon: Icons.search_off,
    );
  }

  /// 検索結果リストを構築
  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return const AppError(
        message: '条件に一致するプロフィールが見つかりませんでした',
        icon: Icons.person_search,
      );
    }

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final gridColumns = ResponsiveHelper.getGridColumns(context);
        final padding = ResponsiveHelper.getSpacing(context, SpacingType.lg);
        final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.small);
        final bodyFontSize = ResponsiveHelper.getFontSize(context, FontSizeType.body);
        
        return Column(
          children: [
            // 結果数表示
            Padding(
              padding: EdgeInsets.all(padding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: AppColors.primaryIndigo,
                      size: iconSize,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                    Text(
                      '${_searchResults.length}件見つかりました',
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 結果リスト - グリッドまたはリスト表示
            Expanded(
              child: gridColumns == 1
                  ? _buildListView(padding)
                  : _buildGridView(gridColumns, padding),
            ),
          ],
        );
      },
    );
  }
  
  /// リスト表示を構築（モバイル用）
  Widget _buildListView(double padding) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: _buildResultCard(_searchResults[index], index),
            ),
          ),
        );
      },
    );
  }
  
  /// グリッド表示を構築（タブレット・デスクトップ用）
  Widget _buildGridView(int gridColumns, double padding) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        childAspectRatio: gridColumns == 2 ? 1.2 : 1.0,
        crossAxisSpacing: ResponsiveHelper.getSpacing(context, SpacingType.md),
        mainAxisSpacing: ResponsiveHelper.getSpacing(context, SpacingType.md),
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              child: _buildResultCard(_searchResults[index], index),
            ),
          ),
        );
      },
    );
  }

  /// 個別の結果カードを構築
  Widget _buildResultCard(Map<String, String> result, int index) {
    // マッチング条件の確認（現在は表示のみで使用していないが、将来的な機能拡張用）

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final cardMargin = deviceType == DeviceType.mobile 
            ? EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, SpacingType.md))
            : EdgeInsets.zero;
        final avatarSize = ResponsiveHelper.getIconSize(context, IconSizeType.large);
        final nameFontSize = ResponsiveHelper.getFontSize(context, FontSizeType.subtitle);
        final departmentFontSize = ResponsiveHelper.getFontSize(context, FontSizeType.body);
        final avatarFontSize = deviceType == DeviceType.mobile ? 20.0 : 24.0;
        final spacing = ResponsiveHelper.getSpacing(context, SpacingType.md);
        final smallSpacing = ResponsiveHelper.getSpacing(context, SpacingType.sm);
        
        return AppCard(
          margin: cardMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー行
              Row(
                children: [
                  // アバター
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(avatarSize / 2),
                    ),
                    child: Center(
                      child: Text(
                        result['name']?.isNotEmpty == true 
                            ? result['name']!.substring(0, 1)
                            : '?',
                        style: TextStyle(
                          fontSize: avatarFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: spacing),
                  
                  // 名前と部署
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['name'] ?? '名前なし',
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result['department'] ?? '部署不明',
                          style: TextStyle(
                            fontSize: departmentFontSize,
                            color: AppColors.textMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: spacing),
              
              // 詳細情報
              _buildHighlightInfoRow(Icons.interests, '趣味', result['hobby'] ?? '不明', widget.hobbies),
              SizedBox(height: smallSpacing),
              _buildHighlightInfoRow(Icons.location_on, '出身地', result['birthplace'] ?? '不明', widget.birthplace),
            ],
          ),
        );
      },
    );
  }



  /// ハイライト付き情報行を構築
  Widget _buildHighlightInfoRow(IconData icon, String label, String value, String query) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final iconSize = ResponsiveHelper.getIconSize(context, IconSizeType.small);
        final fontSize = ResponsiveHelper.getFontSize(context, FontSizeType.body);
        final spacing = ResponsiveHelper.getSpacing(context, SpacingType.sm);
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.textLight,
            ),
            SizedBox(width: spacing),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            Expanded(
              child: HighlightText(
                text: value,
                query: query,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.textDark,
                ),
                isBold: true,
              ),
            ),
          ],
        );
      },
    );
  }

}