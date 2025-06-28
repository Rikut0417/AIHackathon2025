# Me-Too!（ミートゥー） Frontend

Flutter Web アプリケーション

## 主な機能

- Firebase Authentication によるユーザー認証
- レスポンシブデザイン（モバイル・デスクトップ対応）
- プロフィール検索UI
- しおりダウンロード機能
- AI技術を活用したプロフィール検索（趣味・出身地ベース）

## セットアップ

### 1. 依存関係インストール

```bash
flutter pub get
```

### 2. 環境変数設定

```bash
cp .env.example .env
```

`.env`ファイルを編集：

```env
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
# ... 他のFirebase設定

API_BASE_URL=http://localhost:8080
```

### 3. 開発サーバー起動

```bash
flutter run -d web
```

## ビルド

### Web用ビルド
```bash
flutter build web
```

ビルド成果物は `build/web/` に生成されます。

## 環境設定

### ローカル開発
- `API_BASE_URL=http://localhost:8080` (バックエンドローカル)

### 本番環境
- `API_BASE_URL=https://flask-backend-156065435185.us-central1.run.app`

## 使用ライブラリ

- `firebase_core`: Firebase初期化
- `firebase_auth`: 認証機能  
- `http`: API通信
- `shared_preferences`: ローカルストレージ
- `smooth_page_indicator`: ページインジケーター
- `lottie`: アニメーション

## プロジェクト構造

```
lib/
├── main.dart              # エントリーポイント
├── constants/             # 定数・色・スタイル定義
├── services/              # API・認証サービス
├── utils/                 # ユーティリティ
├── widgets/               # 共通ウィジェット
├── login.dart             # ログイン画面
├── home_screen.dart       # ホーム画面
├── search_result.dart     # 検索結果画面
├── onboarding.dart        # オンボーディング
└── splash_screen.dart     # スプラッシュ画面
```

## デバッグ

### Web開発者ツール
ブラウザの開発者ツールでログを確認：
- Firebase認証状態
- API リクエスト/レスポンス
- エラーメッセージ

### Flutter Inspector
VS Code または Android Studio の Flutter Inspector を使用してウィジェット構造を確認