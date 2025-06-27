import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_search_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/highlight_text.dart';
import '../constants/app_colors.dart';

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

  Set<String> _selectedUserNames = <String>{};
  bool _isAllCurrentPageSelected = false;

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
    );
  }

  /// ヘッダー部分を構築
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  '検索結果',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 検索条件サマリー
          AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.primaryIndigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '検索条件',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getSearchSummary(),
                        style: const TextStyle(
                          fontSize: 14,
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
                      color: AppColors.primaryTeal.withOpacity(0.1),
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
  // 380-445行目
  /// 検索結果リストを構築
  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return const AppError(
        message: '条件に一致するプロフィールが見つかりませんでした',
        icon: Icons.person_search,
      );
    }

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
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return _buildResultCard(_searchResults[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 個別の結果カードを構築
  Widget _buildResultCard(Map<String, String> result, int index) {
    final hasMatchedHobby = result['matched_hobby']?.isNotEmpty == true;
    final hasMatchedBirthplace = result['matched_birthplace']?.isNotEmpty == true;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー行
          Row(
            children: [
              // アバター
              Checkbox(
                value: _selectedUserNames.contains(result['name']),
                onChanged: (_) => _toggleUserSelection(result['name'] ?? ''),
                activeColor: AppColors.primaryIndigo,
              ),

              const SizedBox(width: AppSpacing.sm),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    result['name']?.isNotEmpty == true
                        ? result['name']!.substring(0, 1)
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // 名前と部署
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['name'] ?? '名前なし',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result['department'] ?? '部署不明',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 詳細情報
          _buildHighlightInfoRow(Icons.interests, '趣味', result['hobby'] ?? '不明', widget.hobbies),
          const SizedBox(height: AppSpacing.sm),
          _buildHighlightInfoRow(Icons.location_on, '出身地', result['birthplace'] ?? '不明', widget.birthplace),
        ],
      ),
    );
  }



  /// ハイライト付き情報行を構築
  Widget _buildHighlightInfoRow(IconData icon, String label, String value, String query) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
          ),
        ),
        Expanded(
          child: HighlightText(
            text: value,
            query: query,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
            isBold: true,
          ),
        ),
      ],
    );
  }

  /// 選択したメンバーのメンションをコピー
  void _copySelectedMentions() async {
    if (_selectedUserNames.isEmpty) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('コピーに失敗しました: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
