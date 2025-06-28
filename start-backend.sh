#!/bin/bash

# ProfileAI バックエンド開発サーバー起動スクリプト

echo "🚀 ProfileAI バックエンドを起動しています..."

# backend ディレクトリに移動
cd "$(dirname "$0")/backend"

# .env ファイルの存在確認
if [ ! -f ".env" ]; then
    echo "❌ .env ファイルが見つかりません"
    echo "📝 .env.example をコピーして .env ファイルを作成してください："
    echo "   cp .env.example .env"
    echo "📝 その後、.env ファイルを編集して必要な環境変数を設定してください"
    exit 1
fi

# serviceAccountKey.json の存在確認
if [ ! -f "serviceAccountKey.json" ]; then
    echo "❌ serviceAccountKey.json が見つかりません"
    echo "📝 Firebase Console からサービスアカウントキーをダウンロードして配置してください："
    echo "   1. Firebase Console > プロジェクト設定 > サービスアカウント"
    echo "   2. 新しい秘密鍵を生成 > ダウンロード"
    echo "   3. backend/serviceAccountKey.json として保存"
    exit 1
fi

# Python 依存関係の確認
echo "📦 Python 依存関係をチェックしています..."
if ! python -c "import flask" 2>/dev/null; then
    echo "⚠️  依存関係がインストールされていません。インストールしています..."
    pip install -r requirements.txt
fi

echo "✅ バックエンドサーバーを http://localhost:8080 で起動します"
echo "🛑 停止するには Ctrl+C を押してください"
echo ""

# Flask サーバー起動
python main.py