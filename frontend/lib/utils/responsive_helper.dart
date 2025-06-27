import 'package:flutter/material.dart';

/// レスポンシブデザインのためのヘルパークラス
class ResponsiveHelper {
  ResponsiveHelper._();

  // ブレークポイント定義
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// 画面サイズに基づいてデバイスタイプを判定
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// モバイルデバイスかどうかを判定
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// タブレットデバイスかどうかを判定
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// デスクトップデバイスかどうかを判定
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 画面サイズに応じたパディング値を取得
  static EdgeInsets getScreenPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
  }

  /// 画面サイズに応じたカード幅を取得
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth - 32; // 両端16pxずつのマージン
      case DeviceType.tablet:
        return screenWidth * 0.8; // 画面幅の80%
      case DeviceType.desktop:
        return screenWidth > 1400 ? 1200 : screenWidth * 0.7; // 最大1200px
    }
  }

  /// 画面サイズに応じたグリッドの列数を取得
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// 画面サイズに応じたフォントサイズを取得
  static double getFontSize(BuildContext context, FontSizeType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case FontSizeType.title:
        return deviceType == DeviceType.mobile ? 24 : 32;
      case FontSizeType.subtitle:
        return deviceType == DeviceType.mobile ? 18 : 24;
      case FontSizeType.body:
        return deviceType == DeviceType.mobile ? 14 : 16;
      case FontSizeType.caption:
        return deviceType == DeviceType.mobile ? 12 : 14;
    }
  }

  /// 画面サイズに応じたアイコンサイズを取得
  static double getIconSize(BuildContext context, IconSizeType type) {
    final deviceType = getDeviceType(context);
    
    switch (type) {
      case IconSizeType.small:
        return deviceType == DeviceType.mobile ? 16 : 20;
      case IconSizeType.medium:
        return deviceType == DeviceType.mobile ? 24 : 28;
      case IconSizeType.large:
        return deviceType == DeviceType.mobile ? 32 : 40;
      case IconSizeType.xlarge:
        return deviceType == DeviceType.mobile ? 48 : 64;
    }
  }

  /// 画面サイズに応じたボタン高さを取得
  static double getButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.mobile ? 48 : 56;
  }

  /// 画面サイズに応じた最大コンテンツ幅を取得
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth;
      case DeviceType.tablet:
        return 768;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// 画面サイズに応じたスペーシング値を取得
  static double getSpacing(BuildContext context, SpacingType type) {
    final deviceType = getDeviceType(context);
    final multiplier = deviceType == DeviceType.mobile ? 0.8 : 1.0;
    
    switch (type) {
      case SpacingType.xs:
        return 4 * multiplier;
      case SpacingType.sm:
        return 8 * multiplier;
      case SpacingType.md:
        return 16 * multiplier;
      case SpacingType.lg:
        return 24 * multiplier;
      case SpacingType.xl:
        return 32 * multiplier;
      case SpacingType.xxl:
        return 48 * multiplier;
    }
  }

  /// 画面の向きを取得
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// 画面の向きを取得
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// セーフエリアの上部パディングを取得
  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// セーフエリアの下部パディングを取得
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
}

/// デバイスタイプの列挙型
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// フォントサイズタイプの列挙型
enum FontSizeType {
  title,
  subtitle,
  body,
  caption,
}

/// アイコンサイズタイプの列挙型
enum IconSizeType {
  small,
  medium,
  large,
  xlarge,
}

/// スペーシングタイプの列挙型
enum SpacingType {
  xs,
  sm,
  md,
  lg,
  xl,
  xxl,
}

/// レスポンシブビルダーウィジェット
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// レスポンシブラップウィジェット
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerContent;

  const ResponsiveWrapper({
    Key? key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerContent = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveHelper.getMaxContentWidth(context);
    final effectivePadding = padding ?? ResponsiveHelper.getScreenPadding(context);

    Widget content = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: effectivePadding,
      child: child,
    );

    if (centerContent) {
      content = Center(child: content);
    }

    return content;
  }
}