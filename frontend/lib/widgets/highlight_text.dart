import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

/// 検索クエリに一致するテキストをハイライトして表示するウィジェット
class HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final bool isBold;
  final bool showBackground;

  const HighlightText({
    Key? key,
    required this.text,
    required this.query,
    this.style,
    this.isBold = false,
    this.showBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || text.isEmpty) {
      return Text(text, style: style);
    }

    return RichText(
      text: _buildTextSpan(),
    );
  }

  /// ハイライト付きのTextSpanを構築（部分文字列マッチ）
  TextSpan _buildTextSpan() {
    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase().trim();
    
    if (lowerQuery.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
      return TextSpan(children: spans);
    }

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // マッチ前のテキスト
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // マッチしたテキスト（ハイライト）
      final matchedText = text.substring(index, index + lowerQuery.length);
      spans.add(TextSpan(
        text: matchedText,
        style: _getHighlightStyle(),
      ));

      start = index + lowerQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // 残りのテキスト
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return TextSpan(children: spans);
  }

  /// ハイライト用のTextStyleを取得
  TextStyle _getHighlightStyle() {
    final baseStyle = style ?? const TextStyle();
    
    return baseStyle.copyWith(
      color: isBold ? SearchHighlightColors.matchTextBold : SearchHighlightColors.matchText,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
      backgroundColor: showBackground ? SearchHighlightColors.matchBackground : null,
    );
  }
}

/// 複数のクエリでハイライトを行うウィジェット
class MultiHighlightText extends StatelessWidget {
  final String text;
  final List<String> queries;
  final TextStyle? style;
  final bool isBold;
  final bool showBackground;

  const MultiHighlightText({
    Key? key,
    required this.text,
    required this.queries,
    this.style,
    this.isBold = false,
    this.showBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty || text.isEmpty) {
      return Text(text, style: style);
    }

    return RichText(
      text: _buildTextSpan(),
    );
  }

  /// 複数クエリ対応のTextSpanを構築（部分文字列マッチ）
  TextSpan _buildTextSpan() {
    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final List<String> lowerQueries = queries
        .where((q) => q.trim().isNotEmpty)
        .map((q) => q.toLowerCase().trim())
        .toList();
    
    if (lowerQueries.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
      return TextSpan(children: spans);
    }

    // マッチする位置を全て見つける
    final List<MatchPosition> matches = [];
    for (final query in lowerQueries) {
      int index = lowerText.indexOf(query);
      while (index != -1) {
        matches.add(MatchPosition(index, index + query.length));
        index = lowerText.indexOf(query, index + 1);
      }
    }

    // マッチ位置をソートしてマージ
    matches.sort((a, b) => a.start.compareTo(b.start));
    final List<MatchPosition> mergedMatches = _mergeOverlappingMatches(matches);

    // TextSpanを構築
    int start = 0;
    for (final match in mergedMatches) {
      // マッチ前のテキスト
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: style,
        ));
      }

      // マッチしたテキスト（ハイライト）
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: _getHighlightStyle(),
      ));

      start = match.end;
    }

    // 残りのテキスト
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return TextSpan(children: spans);
  }

  /// 重複するマッチ位置をマージ
  List<MatchPosition> _mergeOverlappingMatches(List<MatchPosition> matches) {
    if (matches.isEmpty) return matches;

    final List<MatchPosition> merged = [];
    MatchPosition current = matches[0];

    for (int i = 1; i < matches.length; i++) {
      final next = matches[i];
      if (next.start <= current.end) {
        // 重複または隣接している場合はマージ
        current = MatchPosition(current.start, math.max(current.end, next.end));
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);

    return merged;
  }

  /// ハイライト用のTextStyleを取得
  TextStyle _getHighlightStyle() {
    final baseStyle = style ?? const TextStyle();
    
    return baseStyle.copyWith(
      color: isBold ? SearchHighlightColors.matchTextBold : SearchHighlightColors.matchText,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
      backgroundColor: showBackground ? SearchHighlightColors.matchBackground : null,
    );
  }
}

/// マッチ位置を表すクラス
class MatchPosition {
  final int start;
  final int end;

  MatchPosition(this.start, this.end);
}

/// 完全な単語をハイライトするウィジェット（バックエンドから返される単語リスト使用）
class FullWordHighlightText extends StatelessWidget {
  final String text;
  final List<String> matchedWords;
  final TextStyle? style;
  final bool isBold;
  final bool showBackground;

  const FullWordHighlightText({
    Key? key,
    required this.text,
    required this.matchedWords,
    this.style,
    this.isBold = false,
    this.showBackground = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (matchedWords.isEmpty || text.isEmpty) {
      return Text(text, style: style);
    }

    return RichText(
      text: _buildTextSpan(),
    );
  }

  /// 完全な単語をハイライトするTextSpanを構築
  TextSpan _buildTextSpan() {
    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    
    // マッチする位置を全て見つける
    final List<MatchPosition> matches = [];
    for (final word in matchedWords) {
      if (word.trim().isEmpty) continue;
      final lowerWord = word.toLowerCase().trim();
      int index = lowerText.indexOf(lowerWord);
      while (index != -1) {
        matches.add(MatchPosition(index, index + lowerWord.length));
        index = lowerText.indexOf(lowerWord, index + 1);
      }
    }

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
      return TextSpan(children: spans);
    }

    // マッチ位置をソートしてマージ
    matches.sort((a, b) => a.start.compareTo(b.start));
    final List<MatchPosition> mergedMatches = _mergeOverlappingMatches(matches);

    // TextSpanを構築
    int start = 0;
    for (final match in mergedMatches) {
      // マッチ前のテキスト
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: style,
        ));
      }

      // マッチしたテキスト（完全な単語をハイライト）
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: _getHighlightStyle(),
      ));

      start = match.end;
    }

    // 残りのテキスト
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return TextSpan(children: spans);
  }

  /// 重複するマッチ位置をマージ
  List<MatchPosition> _mergeOverlappingMatches(List<MatchPosition> matches) {
    if (matches.isEmpty) return matches;

    final List<MatchPosition> merged = [];
    MatchPosition current = matches[0];

    for (int i = 1; i < matches.length; i++) {
      final next = matches[i];
      if (next.start <= current.end) {
        // 重複または隣接している場合はマージ
        current = MatchPosition(current.start, math.max(current.end, next.end));
      } else {
        merged.add(current);
        current = next;
      }
    }
    merged.add(current);

    return merged;
  }

  /// ハイライト用のTextStyleを取得
  TextStyle _getHighlightStyle() {
    final baseStyle = style ?? const TextStyle();
    
    return baseStyle.copyWith(
      color: isBold ? SearchHighlightColors.matchTextBold : SearchHighlightColors.matchText,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
      backgroundColor: showBackground ? SearchHighlightColors.matchBackground : null,
    );
  }
}

/// 検索ハイライト用のヘルパー関数
class SearchHighlightHelper {
  /// 文字列が検索クエリの部分文字列を含むかチェック
  static bool isMatch(String text, String query) {
    if (query.trim().isEmpty) return false;
    return text.toLowerCase().contains(query.toLowerCase().trim());
  }

  /// 複数クエリのいずれかの部分文字列にマッチするかチェック
  static bool isMultiMatch(String text, List<String> queries) {
    if (queries.isEmpty) return false;
    final lowerText = text.toLowerCase();
    return queries.any((query) {
      final lowerQuery = query.toLowerCase().trim();
      return lowerQuery.isNotEmpty && lowerText.contains(lowerQuery);
    });
  }
}