# AI ハッカソン 2025 - ProfileAI

<div align="center">
  <h2>🤖 AI技術を活用したプロフィール検索アプリ</h2>
  <p>趣味と出身地から最適なマッチングを見つけるFlutter × Pythonアプリケーション</p>
  
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</div>

## 🚀 クイックスタート（新規参画者向け）

### 📋 前提条件

- [Flutter](https://flutter.dev/docs/get-started/install) (最新安定版)
- [Python](https://python.org/downloads/) (3.8 以上)
- [Git](https://git-scm.com/)

### ⚡ 自動セットアップ

#### 🖥️ フロントエンド（推奨）

````bash
cd frontend
# Linux/macOS
./setup.sh

#### 🐍 バックエンド
```bash
cd backend
pip install -r requirements.txt
python main.py
````

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

### フロントエンド

cd frontend
flutter run

### バックエンド

cd backend
python main.py

### 🎨 **統一デザインシステム**

- スプラッシュ・オンボーディング・メイン画面の完全統一
- グラデーション・アニメーション効果
- レスポンシブデザイン

### 🔍 **スマート検索**

- **両方入力時**: 趣味 AND 出身地（両方一致）
- **片方のみ**: その条件での検索
- リアルタイム結果表示

### 📱 **対応プラットフォーム**

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Desktop (Windows, macOS, Linux)
- 🔄 Mobile (今後対応予定)

## 📚 詳細ドキュメント

- **[frontend/README.md](./frontend/README.md)** - フロントエンド詳細ガイド
- **[frontend/CLAUDE.md](./frontend/CLAUDE.md)** - 開発者向け技術仕様
- **Makefile** - 便利なコマンド一覧

## 🆘 トラブルシューティング

### よくある問題

1. **Flutter 環境エラー**: `flutter doctor` で環境確認
2. **依存関係エラー**: `make clean && make install`
3. **ビルドエラー**: `flutter clean && flutter pub get`

<div align="center">
  <p>🚀 <strong>AIハッカソン2025</strong> で革新的なアプリを作りましょう！</p>
</div>
