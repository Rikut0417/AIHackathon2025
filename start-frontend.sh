#!/bin/bash

# ProfileAI フロントエンド開発サーバー起動スクリプト

echo "🚀 ProfileAI フロントエンドを起動しています..."

# frontend ディレクトリに移動
cd "$(dirname "$0")/frontend"

# .env ファイルの存在確認
if [ ! -f ".env" ]; then
    echo "❌ .env ファイルが見つかりません"
    echo "📝 .env.example をコピーして .env ファイルを作成してください："
    echo "   cp .env.example .env"
    echo "📝 その後、.env ファイルを編集してFirebase設定を行ってください"
    exit 1
fi

# Flutter の存在確認
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter が見つかりません"
    echo "📝 Flutter SDK をインストールしてください："
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Flutter 依存関係の確認とインストール
echo "📦 Flutter 依存関係をチェックしています..."
flutter pub get

echo "✅ フロントエンドサーバーを起動します（Webブラウザが自動で開きます）"
echo "🛑 停止するには Ctrl+C を押してください"
echo ""

# API_BASE_URL を環境変数として読み込み
export $(grep -v '^#' .env | xargs)

# Flutter Web サーバー起動（環境変数を dart-define で渡す）
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=${API_BASE_URL:-http://localhost:8080}