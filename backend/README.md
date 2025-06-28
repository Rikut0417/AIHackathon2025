# ProfileAI Backend

Flask + Firebase Admin SDK + Google Gemini APIを使用したバックエンドサービス

## 主な機能

- ユーザープロフィール検索（趣味・出身地ベース）
- AI生成サークル活動しおり（Gemini API）
- Firebase Authentication & Firestore連携

## セットアップ

### 1. 依存関係インストール

```bash
pip install -r requirements.txt
```

### 2. 環境変数設定

```bash
cp .env.example .env
```

`.env`ファイルを編集：

```env
FIREBASE_SERVICE_ACCOUNT_KEY="./serviceAccountKey.json"
GEMINI_API_KEY="your_actual_api_key"
```

### 3. Firebaseサービスアカウントキー

1. Firebase Consoleからサービスアカウントキー（JSON）をダウンロード
2. `backend/serviceAccountKey.json`として保存

### 4. 起動

```bash
python main.py
```

サーバーは`http://localhost:8080`で起動

## API エンドポイント

### `POST /search`
プロフィール検索

**リクエスト:**
```json
{
  "hobby": "ゲーム",
  "birthplace": "大阪"
}
```

**レスポンス:**
```json
{
  "success": true,
  "users": [...],
  "count": 2
}
```

### `POST /generate-booklet`
しおり生成・ダウンロード

**リクエスト:**
```json
{
  "hobby": "サッカー",
  "birthplace": "神奈川"
}
```

**レスポンス:** TXTファイルダウンロード

### `GET /health`
ヘルスチェック

## 開発時の注意点

- Cloud Run デプロイ時は gunicorn を使用
- ローカル開発時は Flask development server
- 環境変数はすべて`.env`ファイルで管理
- Firebase認証はCloud Run環境では自動認証を使用