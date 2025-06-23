import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '検索アプリ',
      debugShowCheckedModeBanner: false,
      // --- ▼▼▼ Channel.io風のデザインテーマを定義 ▼▼▼ ---
      theme: ThemeData(
        // Channel.io風のカラーパレット
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // インディゴ/パープル系のメインカラー
          background: const Color(0xFFFAFAFA), // 非常に薄いグレー背景
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),

        // モダンなテキストテーマ
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16.0,
            height: 1.6,
            fontWeight: FontWeight.w400,
            color: Color(0xFF374151),
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),

        // クリーンなAppBarテーマ
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),

        // モダンな入力フォームテーマ
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.0),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Channel.io風のボタンテーマ
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // テキストボタンテーマ
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6366F1),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      // --- ▲▲▲ テーマの定義ここまで ▲▲▲ ---
      home: const SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _hobbiesController = TextEditingController();
  final List<String> _ageGroups = ['20代', '30代', '40代', '50代', '60代以上'];
  String? _selectedAgeGroup;
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 検索処理
  void _search() {
    // 入力値のバリデーション
    if (_selectedAgeGroup == null || _hobbiesController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '趣味と年代の両方を入力してください。';
        _searchResults = []; // エラー時は検索結果をクリア
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults = [];
    });

    // モックデータで検索結果をシミュレート
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _searchResults = [
          {
            'name': '山田 太郎',
            'ageGroup': _selectedAgeGroup!,
            'hobbies': _hobbiesController.text,
            'department': '開発部',
          },
          {
            'name': '佐藤 花子',
            'ageGroup': _selectedAgeGroup!,
            'hobbies': _hobbiesController.text,
            'department': '企画部',
          },
          {
            'name': '鈴木 一郎',
            'ageGroup': _selectedAgeGroup!,
            'hobbies': _hobbiesController.text,
            'department': '営業部',
          },
          {
            'name': '田中 美咲',
            'ageGroup': _selectedAgeGroup!,
            'hobbies': _hobbiesController.text,
            'department': '人事部',
          },
          {
            'name': '伊藤 健太',
            'ageGroup': _selectedAgeGroup!,
            'hobbies': _hobbiesController.text,
            'department': '経理部',
          },
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール検索'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // ログイン画面に遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                minimumSize: const Size(80, 36),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('ログイン'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade300, height: 1.0),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 検索フォーム部分 ---
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '検索条件',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'あなたの趣味や年代に合う人を探してみましょう。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          '趣味',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _hobbiesController,
                          decoration: const InputDecoration(
                            hintText: '例: 読書, 旅行',
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          '年代',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedAgeGroup,
                          decoration: InputDecoration(
                            hintText: '年代を選択してください',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                                width: 1.0,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF374151),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF6366F1),
                          ),
                          isExpanded: true,
                          hint: Text(
                            '年代を選択してください',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          items: _ageGroups.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) =>
                              setState(() => _selectedAgeGroup = newValue),
                        ),
                        const SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _search,
                            child: const Text('検索する'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 区切り線 ---
                Container(
                  width: 1,
                  height: MediaQuery.of(context).size.height - 100,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                ),

                // --- 検索結果表示部分 ---
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '検索結果',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResultView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 プロフィール検索アプリ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // プライバシーポリシーの処理
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('プライバシーポリシー'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      // 利用規約の処理
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('利用規約'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ▼▼▼ 結果表示部分のロジックを分離して見やすくする ▼▼▼ ---
  Widget _buildResultView() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }
    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return const Expanded(child: Center(child: Text('条件に合う結果がありませんでした。')));
    }
    return Expanded(
      child: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final person = _searchResults[index];
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade100, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // アバターアイコン
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person['name'] ?? '名前なし',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.1),
                                  const Color(0xFF8B5CF6).withOpacity(0.1),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              person['department'] ?? '部署不明',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '年代:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            person['ageGroup'] ?? '不明',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '趣味:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              person['hobbies'] ?? '不明',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _hobbiesController.dispose();
    super.dispose();
  }
}
