@echo off
REM ProfileAI バックエンド開発サーバー起動スクリプト (Windows)

echo 🚀 ProfileAI バックエンドを起動しています...

REM backend ディレクトリに移動
cd /d "%~dp0backend"

REM .env ファイルの存在確認
if not exist ".env" (
    echo ❌ .env ファイルが見つかりません
    echo 📝 .env.example をコピーして .env ファイルを作成してください：
    echo    copy .env.example .env
    echo 📝 その後、.env ファイルを編集して必要な環境変数を設定してください
    pause
    exit /b 1
)

REM serviceAccountKey.json の存在確認
if not exist "serviceAccountKey.json" (
    echo ❌ serviceAccountKey.json が見つかりません
    echo 📝 Firebase Console からサービスアカウントキーをダウンロードして配置してください：
    echo    1. Firebase Console ^> プロジェクト設定 ^> サービスアカウント
    echo    2. 新しい秘密鍵を生成 ^> ダウンロード
    echo    3. backend\serviceAccountKey.json として保存
    pause
    exit /b 1
)

echo 📦 Python 依存関係をチェックしています...
python -c "import flask" 2>nul
if errorlevel 1 (
    echo ⚠️  依存関係がインストールされていません。インストールしています...
    pip install -r requirements.txt
)

echo ✅ バックエンドサーバーを http://localhost:8080 で起動します
echo 🛑 停止するには Ctrl+C を押してください
echo.

REM Flask サーバー起動
python main.py

pause