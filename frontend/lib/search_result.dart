import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'widgets/common_widgets.dart';
import 'widgets/highlight_text.dart';
import 'services/firebase_search_service.dart';
import 'utils/responsive_helper.dart';
import 'package:flutter/services.dart';

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
  
  // ページネーション関連
  int _currentPage = 0;
  static const int _itemsPerPage = 12;
  late ScrollController _scrollController;

  final Set<String> _selectedUserNames = <String>{};
  bool _isAllCurrentPageSelected = false;

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
      _selectedUserNames.clear();
      _isAllCurrentPageSelected = false;
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
          'name_roman': result['name_roman']?.toString() ?? 'Unknown Name',
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

  void _toggleAllCurrentPageSelection() {
    setState(() {
      if (_isAllCurrentPageSelected) {
        // 全選択解除：現在のページの全ユーザーを選択解除
        for (var result in _searchResults) {
          _selectedUserNames.remove(result['name']);
        }
        _isAllCurrentPageSelected = false;
      } else {
        // 全選択：現在のページの全ユーザーを選択
        for (var result in _searchResults) {
          if (result['name'] != null) {
            _selectedUserNames.add(result['name']!);
          }
        }
        _isAllCurrentPageSelected = true;
      }
    });
  }

  void _toggleUserSelection(String userName) {
    setState(() {
      if (_selectedUserNames.contains(userName)) {
        _selectedUserNames.remove(userName);
      } else {
        _selectedUserNames.add(userName);
      }

      // 全選択状態の更新
      _isAllCurrentPageSelected = _searchResults.every((result) =>
        result['name'] != null && _selectedUserNames.contains(result['name']!));
    });
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
    // ページネーション情報の計算
    final totalPages = _searchResults.isNotEmpty ? (_searchResults.length / _itemsPerPage).ceil() : 0;
    final showPagination = totalPages > 1;
    
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
          child: Stack(
            children: [
              // メインコンテンツ（全体スクロール可能）
              ResponsiveWrapper(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ヘッダー
                      _buildHeader(),
                      
                      // 検索情報バー（常に表示）
                      _buildSearchInfoBar(),
                      
                      // メインコンテンツ
                      _isLoading
                          ? _buildLoadingState()
                          : _errorMessage != null
                              ? _buildErrorState()
                              : _buildResultsList(),
                      
                      // ページネーションボタン用の余白（固定ボタンの高さ分）
                      if (showPagination)
                        SizedBox(height: ResponsiveHelper.getSpacing(context, SpacingType.xxl) + 60),
                    ],
                  ),
                ),
              ),
              
              // 固定ページネーションボタン
              if (showPagination)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildFixedPagination(totalPages),
                ),
            ],
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
              // タイトル行
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      color: AppColors.primaryIndigo,
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

  /// 検索情報バーを構築（常に表示）
  Widget _buildSearchInfoBar() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final padding = ResponsiveHelper.getSpacing(context, SpacingType.lg);
        
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              if (!_isLoading && _errorMessage == null && _searchResults.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.group_add,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Text(
                          '招待したい人のチェックボックスにチェックを入れて、出力ボタンを押してください',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

    final totalPages = (_searchResults.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _searchResults.length);
    final currentPageResults = _searchResults.sublist(startIndex, endIndex);

    return Column(
      children: [
        // 結果数とコントロール
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 結果数表示
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: AppColors.primaryIndigo,
                      size: 24,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.sm)),
                    Text(
                      '${_searchResults.length}件見つかりました',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                // ページ情報表示
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${_currentPage + 1} / $totalPages ページ',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // 選択操作エリア
                Row(
                  children: [
                    // 全選択チェックボックス
                    Row(
                      children: [
                        Checkbox(
                          value: _isAllCurrentPageSelected,
                          onChanged: (_) => _toggleAllCurrentPageSelection(),
                          activeColor: AppColors.primaryIndigo,
                        ),
                        const Text(
                          'すべて選択',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: AppSpacing.lg),

                    // メンション出力ボタン
                    Expanded(
                      child: AppButton(
                        text: '選択したメンバーのメンションをコピー',
                        onPressed: _copySelectedMentions,
                        backgroundColor: AppColors.accentCyan,
                        icon: Icons.content_copy,
                        height: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 検索結果リスト
        SlideTransition(
          position: _slideAnimation,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentPageResults.length,
            itemBuilder: (context, index) {
              return _buildResultCard(currentPageResults[index], index);
            },
          ),
        ),
      ],
    );
  }

  /// 個別の結果カードを構築
  Widget _buildResultCard(Map<String, String> result, int index) {
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
                  // チェックボックス
                  Checkbox(
                    value: _selectedUserNames.contains(result['name']),
                    onChanged: (_) => _toggleUserSelection(result['name'] ?? ''),
                    activeColor: AppColors.primaryIndigo,
                  ),

                  const SizedBox(width: AppSpacing.sm),

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

  /// 固定ページネーションUIを構築
  Widget _buildFixedPagination(int totalPages) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SpacingType.lg)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 前に戻るボタン
              _buildPaginationButton(
                icon: Icons.arrow_back_ios,
                text: '前に戻る',
                onPressed: _currentPage > 0 ? () => _changePage(_currentPage - 1) : null,
              ),
              
              // 中央スペース
              const Expanded(child: SizedBox()),
              
              // 次に進むボタン
              _buildPaginationButton(
                icon: Icons.arrow_forward_ios,
                text: '次に進む',
                onPressed: _currentPage < totalPages - 1 ? () => _changePage(_currentPage + 1) : null,
                isReversed: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ページネーションボタンを構築
  Widget _buildPaginationButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    bool isReversed = false,
  }) {
    final isEnabled = onPressed != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getSpacing(context, SpacingType.md),
            vertical: ResponsiveHelper.getSpacing(context, SpacingType.sm),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? AppColors.primaryIndigo : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isReversed
                ? [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                        fontWeight: FontWeight.w500,
                        color: isEnabled ? AppColors.primaryIndigo : AppColors.textLight,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.xs)),
                    Icon(
                      icon,
                      size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                      color: isEnabled ? AppColors.primaryIndigo : AppColors.textLight,
                    ),
                  ]
                : [
                    Icon(
                      icon,
                      size: ResponsiveHelper.getIconSize(context, IconSizeType.small),
                      color: isEnabled ? AppColors.primaryIndigo : AppColors.textLight,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context, SpacingType.xs)),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, FontSizeType.caption),
                        fontWeight: FontWeight.w500,
                        color: isEnabled ? AppColors.primaryIndigo : AppColors.textLight,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  /// 選択したメンバーのメンションをコピー
  void _copySelectedMentions() async {
    if (_selectedUserNames.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メンバーを選択してください'),
          backgroundColor: AppColors.warningYellow,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final mentions = <String>[];

      for (final userName in _selectedUserNames) {
        // 選択されたユーザーの詳細情報を取得
        final userResult = _searchResults.firstWhere(
          (result) => result['name'] == userName,
          orElse: () => <String, String>{},
        );

        if (userResult.isNotEmpty) {
          final name = userResult['name'] ?? '名前なし';
          final romanName = userResult['name_roman'] ?? 'Unknown Name';
          final department = userResult['department'] ?? '部署不明';

          // メンション形式の安全な構築
          final safeName = name.replaceAll('（', '(').replaceAll('）', ')');
          final safeDepartment = department.replaceAll('（', '(').replaceAll('）', ')');

          // メンション形式: @"ローマ字名前""漢字名前""（""部署名""）"
          final mention = '@$romanName$safeName（$safeDepartment）';
          mentions.add(mention);
        }
      }

      if (mentions.isNotEmpty) {
        // 改行区切りでクリップボードにコピー
        final mentionText = mentions.join('\n');
        await Clipboard.setData(ClipboardData(text: mentionText));

        // 成功通知（改行を半角スペースに置き換えて表示）
        final displayText = mentions.join(' ');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('「$displayText」をクリップボードにコピーしました'),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // エラー通知
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('コピーに失敗しました: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// ページを変更
  void _changePage(int newPage) {
    setState(() {
      _currentPage = newPage;
    });
    
    // 検索結果欄の先頭にスクロール
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    
    // アニメーションをリセットして再開
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }
}