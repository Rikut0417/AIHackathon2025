import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'login.dart';
import 'constants/app_colors.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .envファイルを読み込み
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Firebase初期化後の認証状態を確認
  final authService = AuthService();
  print('🚀 App started - Current user: ${authService.currentUser?.email ?? "Not logged in"}');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Me-Too!（ミートゥー）',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryIndigo,
          background: AppColors.backgroundLight,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16.0,
            height: 1.6,
            fontWeight: FontWeight.w400,
            color: AppColors.textMedium,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardBackground,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// 認証状態ラッパー
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isFirstLaunchChecked = false;
  bool _isFirstLaunch = true;
  bool _splashComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // アプリ初期化（スプラッシュ画面の最低表示時間を確保）
  Future<void> _initializeApp() async {
    // 最低3秒間スプラッシュ画面を表示
    final splashTimer = Future.delayed(const Duration(seconds: 3));
    final firstLaunchCheck = _checkFirstLaunch();
    
    // 両方の処理が完了するまで待機
    await Future.wait([splashTimer, firstLaunchCheck]);
    
    setState(() {
      _splashComplete = true;
    });
  }

  // 初回起動チェック
  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      
      setState(() {
        _isFirstLaunch = isFirstLaunch;
        _isFirstLaunchChecked = true;
      });
    } catch (e) {
      print('❌ Error checking first launch: $e');
      setState(() {
        _isFirstLaunch = false;
        _isFirstLaunchChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // スプラッシュ画面表示期間またはデータロード中はスプラッシュ画面を表示
    if (!_splashComplete || !_isFirstLaunchChecked) {
      return SplashScreen(isFirstLaunch: _isFirstLaunch);
    }

    // 初回起動の場合はオンボーディング画面
    if (_isFirstLaunch) {
      return const OnboardingScreen();
    }

    // 2回目以降の起動：認証状態をチェック
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        print('🔄 AuthWrapper rebuild - ConnectionState: ${snapshot.connectionState}');
        print('📊 Has data: ${snapshot.hasData}');
        print('👤 User: ${snapshot.data?.email ?? "null"}');
        print('🔍 Snapshot error: ${snapshot.error}');
        
        // エラーがある場合はログイン画面を表示
        if (snapshot.hasError) {
          print('❌ Auth error - Showing LoginScreen');
          return const LoginScreen();
        }
        
        // 接続待機中はスプラッシュ画面（ローディング中）
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Showing SplashScreen (loading)');
          return const SplashScreen(isFirstLaunch: false);
        }
        
        // データがある（ログイン済み）の場合はホーム画面
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User logged in - Showing HomeScreen');
          return const HomeScreen();
        } else {
          // データがない（未ログイン）の場合はログイン画面
          print('❌ User not logged in - Showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}

// 既存のSearchScreenクラスをHomeScreenに置き換える互換性のためのエイリアス
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}