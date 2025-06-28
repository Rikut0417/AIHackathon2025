# AI ハッカソン 2025 - Me-Too!（ミートゥー）

## 🛠️ 技術スタック

| 分野 | 技術 | 目的 |
|------|------|------|
| **フロントエンド** | Flutter (Dart) | クロスプラットフォーム対応のUIアプリ |
| **バックエンド** | Python (Flask) | API サーバー・データ処理 |
| **データベース** | Firebase Realtime DB | ユーザーデータ・検索結果保存 |
| **認証** | Firebase Auth | ユーザー認証・セキュリティ |
| **デプロイ** | Google Cloud Platform | 本番環境への配信 |

## 🚀 クイックスタート（新規参画者向け）

### 📋 前提条件

以下のソフトウェアをインストールしてください：

| ソフトウェア | バージョン | インストールリンク | 必須度 |
|-------------|-----------|------------------|-------|
| **Flutter** | 最新安定版 | [flutter.dev](https://flutter.dev/docs/get-started/install) | 🔴 必須 |
| **Python** | 3.8 以上 | [python.org](https://python.org/downloads/) | 🔴 必須 |
| **Git** | 最新版 | [git-scm.com](https://git-scm.com/) | 🔴 必須 |
| **VS Code** | 最新版 | [code.visualstudio.com](https://code.visualstudio.com/) | 🟡 推奨 |

#### 1️⃣ リポジトリのクローン

```bash
git clone <repository-url>
cd AIHackathon2025
```

#### 2️⃣ フロントエンド（Flutter）の設定

```bash
cd frontend

#セットアップ
flutter pub get
```

#### 3️⃣ バックエンド（Python）の設定

```bash
cd backend

# 仮想環境の作成（推奨）
python -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate     # Windows

# 依存関係のインストール
pip install -r ../requirements.txt

```

#### 4️⃣ 開発環境の確認

### フロントエンド

cd frontend
flutter run

### バックエンド

cd backend
python main.py

## 📁 プロジェクト構成

```
AIHackathon2025/
├── frontend/           # Flutter アプリケーション
│   ├── lib/
│   │   ├── splash_screen.dart      # スプラッシュ画面
│   │   ├── onboarding_screen.dart  # オンボーディング
│   │   ├── home_screen.dart        # ホーム画面
│   │   ├── search_result.dart      # 検索結果
│   │   └── constants/              # デザインシステム
│   ├── README.md       # フロントエンド詳細ドキュメント
│   ├── setup.sh        # 自動セットアップスクリプト
│   └── Makefile        # 開発用コマンド
├── backend/            # Python API サーバー
│   └── main.py         # Flask サーバー
└── README.md           # このファイル
```

```

### 💡 開発のヒント

- **フロントエンド**: `lib/` フォルダ内のファイルを編集
- **バックエンド**: `backend/main.py` を中心に開発
- **デザイン**: `lib/constants/app_colors.dart` で統一カラーを管理
- **テスト**: 新機能追加時は必ずテストも追加



### よくある問題と解決方法

| 問題 | 症状 | 解決方法 |
|------|------|----------|
| **Flutter 環境エラー** | `flutter doctor` でエラー | 不足しているツールをインストール |
| **依存関係エラー** | `pub get` 失敗 | `flutter clean && flutter pub get` |
| **ビルドエラー** | コンパイルエラー | `flutter clean && flutter pub upgrade` |
| **サーバー接続エラー** | API 呼び出し失敗 | バックエンドが起動しているか確認 |
| **CORS エラー** | Web でAPI エラー | `--web-browser-flag "--disable-web-security"` |


# 1. フロントエンド起動（ターミナル1）
cd frontend && flutter run -d web-server

# 2. バックエンド起動（ターミナル2）
cd backend && python main.py

