# ProfileAI - CLI起動方法

## 概要
ProfileAIアプリケーションをコマンドライン（CLI）から起動する方法を説明します。

## 前提条件
- Python 3.11+ がインストール済み
- Flutter 3.2+ がインストール済み
- 環境変数ファイル（.env）が適切に設定済み

## 🚀 1. バックエンドの起動

### 手動起動（CLI）

#### Linux/Mac
```bash
# 1. backendディレクトリに移動
cd backend

# 2. Python依存関係インストール（初回のみ）
pip install -r requirements.txt

# 3. Flask開発サーバー起動
python main.py
```

#### Windows
```cmd
REM 1. backendディレクトリに移動
cd backend

REM 2. Python依存関係インストール（初回のみ）
pip install -r requirements.txt

REM 3. Flask開発サーバー起動
python main.py
```

### 自動起動スクリプト

#### Linux/Mac
```bash
# プロジェクトルートから実行
./start-backend.sh
```

#### Windows
```cmd
REM プロジェクトルートから実行
start-backend.bat
```

**バックエンドサーバー**: `http://localhost:8080`

---

## 🎨 2. フロントエンドの起動

### 手動起動（CLI）

#### Linux/Mac
```bash
# 1. frontendディレクトリに移動
cd frontend

# 2. Flutter依存関係取得（初回のみ）
flutter pub get

# 3. 環境変数を読み込み
export $(grep -v '^#' .env | xargs)

# 4. Flutter Web開発サーバー起動
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=${API_BASE_URL:-http://localhost:8080}
```

#### Windows
```cmd
REM 1. frontendディレクトリに移動
cd frontend

REM 2. Flutter依存関係取得（初回のみ）
flutter pub get

REM 3. .envファイルからAPI_BASE_URLを読み取り（手動で設定）
set API_BASE_URL=http://localhost:8080

REM 4. Flutter Web開発サーバー起動
flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=%API_BASE_URL%
```

### 自動起動スクリプト

#### Linux/Mac
```bash
# プロジェクトルートから実行
./start-frontend.sh
```

#### Windows
```cmd
REM プロジェクトルートから実行
start-frontend.bat
```

**フロントエンドサーバー**: `http://localhost:3000`

---

## 🔧 3. 両方同時起動

### ターミナル2つを使用
```bash
# ターミナル1: バックエンド
cd backend && python main.py

# ターミナル2: フロントエンド
cd frontend && flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

### tmux/screen使用（Linux/Mac）
```bash
# tmux セッション作成
tmux new-session -d -s profileai

# バックエンド用ウィンドウ
tmux send-keys -t profileai 'cd backend && python main.py' Enter

# フロントエンド用ウィンドウ
tmux new-window -t profileai
tmux send-keys -t profileai 'cd frontend && flutter run -d web-server --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080' Enter

# セッションにアタッチ
tmux attach-session -t profileai
```

---

## 🛠️ トラブルシューティング

### よくあるエラーと対処法

#### 1. Python関連エラー
```bash
# 仮想環境作成（推奨）
python -m venv venv
source venv/bin/activate  # Linux/Mac
# または
venv\Scripts\activate.bat  # Windows

# 依存関係再インストール
pip install -r requirements.txt
```

#### 2. Flutter関連エラー
```bash
# Flutterキャッシュクリア
flutter clean
flutter pub get

# Flutter Webサポート確認
flutter config --enable-web
flutter devices
```

#### 3. ポート競合エラー
```bash
# ポート使用状況確認
lsof -i :8080  # Mac/Linux
netstat -ano | findstr :8080  # Windows

# 異なるポートで起動
python main.py  # バックエンドはmain.py内でPORT環境変数を確認
flutter run -d web-server --web-port 3001  # フロントエンド
```

#### 4. 環境変数エラー
```bash
# .envファイル確認
cat backend/.env
cat frontend/.env

# 必要な変数が設定されているか確認
echo $API_BASE_URL
```

---

## 🏃‍♂️ 開発時のワークフロー

### 推奨手順
1. **初回セットアップ**: 環境変数ファイル設定
2. **バックエンド起動**: `./start-backend.sh`
3. **フロントエンド起動**: `./start-frontend.sh`
4. **ブラウザアクセス**: `http://localhost:3000`

### ホットリロード
- **バックエンド**: ファイル変更時は手動再起動が必要
- **フロントエンド**: Flutter hot reloadが自動で動作

---

## 📝 メモ

- バックエンドを先に起動してからフロントエンドを起動することを推奨
- 開発中はログを確認できるよう、各ターミナルを開いたままにする
- 本番デプロイ時は自動起動スクリプトではなく、Dockerfileを使用