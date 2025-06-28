@echo off
REM ProfileAI フロントエンド開発サーバー起動スクリプト (Windows)

echo 🚀 ProfileAI フロントエンドを起動しています...

REM frontend ディレクトリに移動
cd /d "%~dp0frontend"

REM .env ファイルの存在確認
if not exist ".env" (
    echo ❌ .env ファイルが見つかりません
    echo 📝 .env.example をコピーして .env ファイルを作成してください：
    echo    copy .env.example .env
    echo 📝 その後、.env ファイルを編集してFirebase設定を行ってください
    pause
    exit /b 1
)

REM Flutter の存在確認
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter が見つかりません
    echo 📝 Flutter SDK をインストールしてください：
    echo    https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo 📦 Flutter 依存関係をチェックしています...
flutter pub get

echo ✅ フロントエンドサーバーを起動します（Webブラウザが自動で開きます）
echo 🛑 停止するには Ctrl+C を押してください
echo.

REM .env ファイルから API_BASE_URL を読み取り
for /f "usebackq tokens=1,2 delims==" %%i in (".env") do (
    if "%%i"=="API_BASE_URL" set API_BASE_URL=%%j
)

REM デフォルト値設定
if "%API_BASE_URL%"=="" set API_BASE_URL=http://localhost:8080

REM Flutter Web サーバー起動
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=%API_BASE_URL%

pause