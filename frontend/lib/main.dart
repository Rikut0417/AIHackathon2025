import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfileAI',
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
      home: const SplashScreen(),
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