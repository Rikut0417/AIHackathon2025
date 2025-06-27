import 'package:flutter/material.dart';

/// アプリ全体で使用する統一カラーパレット
/// スプラッシュ・オンボーディング画面との一貫性を保つ
class AppColors {
  AppColors._(); // プライベートコンストラクタ

  // === プライマリカラー ===
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color successGreen = Color(0xFF10B981);
  static const Color primaryTeal = Color(0xFF009688);

  // === 背景色 ===
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFAFAFA);

  // === テキスト色 ===
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMedium = Color(0xFF475569);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // === グラデーション ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryIndigo, secondaryPurple],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, primaryIndigo],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // === シャドウ ===
  static const Color shadowColor = Color(0x1A000000);
  static const Color softShadowColor = Color(0x0F000000);

  // === ボーダー ===
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  // === ステータス色 ===
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  // === オーバーレイ ===
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
}

/// アプリ全体で使用するシャドウスタイル
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.softShadowColor,
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> strong = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];
}

/// アプリ全体で使用するボーダー半径
class AppRadius {
  AppRadius._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double xxlarge = 24.0;
  static const double circle = 999.0;

  static BorderRadius get smallBorder => BorderRadius.circular(small);
  static BorderRadius get mediumBorder => BorderRadius.circular(medium);
  static BorderRadius get largeBorder => BorderRadius.circular(large);
  static BorderRadius get xlargeBorder => BorderRadius.circular(xlarge);
  static BorderRadius get xxlargeBorder => BorderRadius.circular(xxlarge);
}

/// アプリ全体で使用するスペーシング
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// 検索結果ハイライト用カラーパレット
class SearchHighlightColors {
  SearchHighlightColors._();

  // メインハイライト色（赤系）
  static const Color matchText = Color(0xFFE53E3E);           // 濃い赤
  static const Color matchTextBold = Color(0xFFC53030);       // より濃い赤（太字用）

  // 背景ハイライト（オプション）
  static const Color matchBackground = Color(0xFFFED7D7);     // 薄い赤背景
  static const Color matchBorder = Color(0xFFFEB2B2);        // 薄い赤ボーダー

  // 通常テキスト
  static const Color normalText = Color(0xFF1E293B);         // ダークグレー
  static const Color secondaryText = Color(0xFF64748B);      // グレー
}
