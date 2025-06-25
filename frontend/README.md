# ProfileAI - AI ハッカソン 2025 フロントエンドアプリ

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Material_Design-0081CB?style=for-the-badge&logo=material-design&logoColor=white" />
</div>

## 📖 概要

ProfileAI は、AI 技術を活用したプロフィール検索アプリです。ユーザーは趣味や出身地を入力することで、条件に一致する人を検索できます。

### ✨ 主な機能

- 🤖 **AI 検索**: 高度な AI アルゴリズムによる精密な検索
- ⚡ **高速検索**: リアルタイムで瞬時に結果を表示
- 🎨 **美しい UI**: スプラッシュ・オンボーディング・メイン画面の統一デザイン
- 📱 **レスポンシブ**: 様々な画面サイズに対応
- 🔄 **スムーズなアニメーション**: 60FPS の滑らかな画面遷移

### 🎯 検索条件

- **両方入力時**: 趣味 **AND** 出身地（両方一致）
- **片方のみ**: その条件での検索

## 🚀 クイックスタート

### 前提条件

以下のソフトウェアがインストールされている必要があります：

- [Flutter](https://flutter.dev/docs/get-started/install) (推奨: 最新の安定版)
- [Dart](https://dart.dev/get-dart) (Flutter に含まれています)
- [Git](https://git-scm.com/)
- お好みのエディタ ([VS Code](https://code.visualstudio.com/) または [Android Studio](https://developer.android.com/studio))

### 📦 セットアップ手順

#### 1. リポジトリのクローン

```bash
git clone https://github.com/your-org/AIHackathon2025.git
cd AIHackathon2025/frontend
```

#### 2. 依存関係のインストール

```bash
# パッケージの取得
flutter pub get

# 依存関係の確認
flutter doctor
```

#### 3. アプリケーションの実行

##### デバッグモード（開発用）

```bash
# デフォルトデバイスで実行
flutter run

# 特定のデバイスで実行
flutter run -d chrome          # Webブラウザ
flutter run -d linux           # Linux デスクトップ
flutter run -d windows         # Windows デスクトップ
flutter run -d macos           # macOS デスクトップ
```

##### プロダクションビルド

```bash
# Web用ビルド
flutter build web

# デスクトップ用ビルド
flutter build linux            # Linux
flutter build windows          # Windows
flutter build macos            # macOS
```

## 🛠️ 開発コマンド

### 📊 コード品質

```bash
# 静的解析の実行
flutter analyze

# コードフォーマット
flutter format .

# テストの実行
flutter test

# 依存関係の更新
flutter pub upgrade
```

### 🧹 クリーンアップ

```bash
# ビルド成果物のクリア
flutter clean

# 依存関係の再インストール
flutter pub get
```

### 🔍 デバッグ

```bash
# デバッグ情報付きで実行
flutter run --debug

# プロファイルモードで実行
flutter run --profile

# リリースモードで実行
flutter run --release
```

## 📁 プロジェクト構成

```
frontend/
├── lib/
│   ├── constants/              # 定数・設定
│   │   └── app_colors.dart     # カラーパレット
│   ├── widgets/                # 共通ウィジェット
│   │   └── common_widgets.dart # 再利用可能なUIコンポーネント
│   ├── services/               # API・データサービス
│   │   └── firebase_search_service.dart
│   ├── splash_screen.dart      # スプラッシュ画面
│   ├── onboarding_screen.dart  # オンボーディング
│   ├── home_screen.dart        # ホーム画面
│   ├── search_result.dart      # 検索結果画面
│   ├── login.dart              # ログイン画面
│   └── main.dart               # アプリエントリーポイント
├── pubspec.yaml                # 依存関係設定
├── README.md                   # このファイル
└── CLAUDE.md                   # 開発者向け詳細ドキュメント
```

## 📦 使用パッケージ

### 主要依存関係

| パッケージ          | バージョン | 用途                   |
| ------------------- | ---------- | ---------------------- |
| **flutter**         | SDK        | Flutter フレームワーク |
| **cupertino_icons** | ^1.0.2     | iOS スタイルアイコン   |
| **http**            | ^1.1.0     | HTTP 通信              |

### 追加パッケージ

| パッケージ                | バージョン | 用途                                 |
| ------------------------- | ---------- | ------------------------------------ |
| **shared_preferences**    | ^2.2.0     | 初回起動判定・設定永続化             |
| **smooth_page_indicator** | ^1.1.0     | オンボーディングページインジケーター |
| **lottie**                | ^2.6.0     | 高品質アニメーション（将来用）       |

### 開発用依存関係

| パッケージ        | バージョン | 用途                 |
| ----------------- | ---------- | -------------------- |
| **flutter_test**  | SDK        | テストフレームワーク |
| **flutter_lints** | ^2.0.0     | コード品質チェック   |

## 🎨 デザインシステム

### カラーパレット

- **Primary**: `#6366F1` (Indigo)
- **Secondary**: `#8B5CF6` (Purple)
- **Accent**: `#06B6D4` (Cyan)
- **Background**: `#F8FAFC` (Light Gray)
- **Text**: `#1E293B` (Dark Gray)

### 統一コンポーネント

- `AppCard` - 統一されたカードデザイン
- `AppButton` - 一貫したボタンスタイル
- `AppTextField` - 統一された入力フィールド
- `AppLoading` - ローディング表示
- `AppError` - エラー表示

## 🔧 バックエンド連携

### リクエスト形式

```json
{
  "hobby": "サッカー",
  "birthplace": "東京都"
}
```

### レスポンス形式

```json
{
  "success": true,
  "users": [
    {
      "name": "田中太郎",
      "hobby": "サッカー, 映画鑑賞",
      "birthplace": "東京都",
      "department": "開発部",
      "matched_hobby": "サッカー",
      "matched_birthplace": "東京都"
    }
  ],
  "count": 1
}
```

## 🚨 トラブルシューティング

### よくある問題と解決方法

#### 1. パッケージ取得エラー

```bash
# 解決方法
flutter clean
flutter pub get
```

#### 2. ビルドエラー

```bash
# キャッシュをクリア
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. 依存関係の競合

```bash
# 依存関係ツリーの確認
flutter pub deps

# 特定のパッケージバージョンを確認
flutter pub deps --style=tree
```

#### 4. Hot Reload が動作しない

- アプリを完全に再起動: `r` キー
- Hot Restart: `R` キー
- 開発サーバーの再起動: `Ctrl+C` → `flutter run`

#### 5. Web 実行時の CORS エラー

```bash
# Chrome で CORS を無効化して起動
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### 🔍 デバッグ情報

```bash
# Flutter環境の詳細情報
flutter doctor -v

# 接続デバイスの確認
flutter devices

# パフォーマンス情報
flutter run --profile
```

## 🤝 開発ガイドライン

### コードスタイル

- [Effective Dart](https://dart.dev/guides/language/effective-dart) に従う
- `flutter format` でコードを整形
- `flutter analyze` でコード品質をチェック

### アニメーション実装

- 60FPS を目標とする
- `AnimationController` と `Tween` を活用
- メモリリークを防ぐため `dispose()` を確実に呼ぶ

## 📱 対応プラットフォーム

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Linux Desktop**
- ✅ **Windows Desktop**
- ✅ **macOS Desktop**
- 🔄 **Android** (今後対応予定)
- 🔄 **iOS** (今後対応予定)

<div align="center">
  <p>🚀 <strong>AIハッカソン2025</strong> で素晴らしいアプリを作りましょう！</p>
</div>
