# AI ハッカソン 2025 - Me-Too!（ミートゥー）

## 概要

Me-Too!（ミートゥー）は、趣味や出身地を基にしたAIプロフィール検索アプリケーションです。FirebaseとGoogle Gemini APIを活用して、ユーザー同士のマッチングと、マッチした興味に基づくサークル活動のしおりの自動生成機能を提供します。

## 技術スタック

### バックエンド
- **Python 3.11**
- **Flask** - WebAPIフレームワーク
- **Firebase Admin SDK** - 認証・データベース
- **Google Gemini API** - しおり生成
- **Firestore** - NoSQLデータベース

### フロントエンド
- **Flutter 3.2+** - クロスプラットフォーム開発
- **Firebase Auth** - ユーザー認証
- **HTTP** - API通信

## 機能

- ✅ **ユーザー認証** (Firebase Auth)
- ✅ **プロフィール検索** (趣味・出身地ベース)
- ✅ **AI生成しおり** (Gemini API使用)
- ✅ **レスポンシブデザイン**

## ローカル開発環境のセットアップ

### 前提条件

以下のツールがインストールされている必要があります：

- **Python 3.11+**
- **Flutter 3.2+**
- **Git**

### 1. リポジトリのクローン

\`\`\`bash
git clone <repository-url>
cd AIHackathon2025
\`\`\`

### 2. バックエンドのセットアップ

#### 2.1 依存関係のインストール

\`\`\`bash
cd backend
pip install -r requirements.txt
\`\`\`

#### 2.2 環境変数の設定

\`\`\`bash
# .env.exampleをコピーして編集
cp .env.example .env
\`\`\`

\`.env\`ファイルを以下のように設定：

\`\`\`env
# Firebase設定
FIREBASE_SERVICE_ACCOUNT_KEY="./serviceAccountKey.json"

# Google Gemini API設定
GEMINI_API_KEY="your_actual_gemini_api_key"

# Google Custom Search API設定 (任意)
GOOGLE_SEARCH_API_KEY="your_google_search_api_key"
GOOGLE_SEARCH_ENGINE_ID="your_search_engine_id"
\`\`\`

#### 2.3 Firebaseサービスアカウントキーの配置

1. Firebase Console から サービスアカウントキー（JSON）をダウンロード
2. \`backend/serviceAccountKey.json\` として保存

#### 2.4 バックエンドの起動

\`\`\`bash
# backend/ディレクトリで実行
python main.py
\`\`\`

サーバーは \`http://localhost:8080\` で起動します。

### 3. フロントエンドのセットアップ

#### 3.1 依存関係のインストール

\`\`\`bash
cd frontend
flutter pub get
\`\`\`

#### 3.2 環境変数の設定

\`\`\`bash
# .env.exampleをコピーして編集
cp .env.example .env
\`\`\`

\`.env\`ファイルを以下のように設定：

\`\`\`env
# Firebase設定（Firebase Consoleから取得）
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_DATABASE_URL=https://your_project-default-rtdb.firebaseio.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# API Base URL
API_BASE_URL=http://localhost:8080
\`\`\`

#### 3.3 フロントエンドの起動

\`\`\`bash
# frontend/ディレクトリで実行
flutter run -d web
\`\`\`

アプリケーションは \`http://localhost:3000\` (または自動割り当てポート) で起動します。

## API設定方法

### Google Gemini API

1. [Google AI Studio](https://makersuite.google.com/app/apikey) にアクセス
2. APIキーを作成
3. \`backend/.env\` の \`GEMINI_API_KEY\` に設定

### Firebase設定

1. [Firebase Console](https://console.firebase.google.com/) でプロジェクト作成
2. Authentication, Firestore を有効化
3. ウェブアプリを追加してConfig情報を取得
4. \`frontend/.env\` に設定

## 開発用コマンド

### バックエンド

\`\`\`bash
# 開発サーバー起動
cd backend
python main.py

# 依存関係追加時
pip freeze > requirements.txt
\`\`\`

### フロントエンド

\`\`\`bash
# Web開発
flutter run -d web

# 依存関係の取得
flutter pub get

# ビルド
flutter build web
\`\`\`

## デプロイ

### Google Cloud Run (本番環境)

プロジェクトは既にGoogle Cloud Runにデプロイされています：

- **フロントエンド**: https://flutter-frontend-156065435185.us-central1.run.app
- **バックエンド**: https://flask-backend-156065435185.us-central1.run.app

## トラブルシューティング

### よくある問題

1. **Firebase接続エラー**
   - サービスアカウントキーのパスを確認
   - Firebase プロジェクトの設定を確認

2. **Flutter pub get エラー**
   - Flutter SDKのバージョンを確認
   - \`flutter clean && flutter pub get\` を実行

3. **API接続エラー**
   - バックエンドが起動しているか確認
   - \`.env\` の \`API_BASE_URL\` を確認

## プロジェクト構造

\`\`\`
AIHackathon2025/
├── backend/              # Flaskバックエンド
│   ├── main.py          # メインアプリケーション
│   ├── requirements.txt # Python依存関係
│   ├── .env            # 環境変数（要設定）
│   └── .env.example    # 環境変数テンプレート
├── frontend/            # Flutterフロントエンド
│   ├── lib/            # Dartソースコード
│   ├── pubspec.yaml    # Flutter依存関係
│   ├── .env           # 環境変数（要設定）
│   └── .env.example   # 環境変数テンプレート
├── .gitignore          # Git無視ファイル
└── README.md           # このファイル
\`\`\`

## ライセンス

このプロジェクトは内部開発用です。

## 貢献

1. Feature ブランチを作成
2. 変更をコミット
3. プルリクエストを作成

## 開発チーム

AIハッカソン2025 チーム