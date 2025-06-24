### Backend起動
cd backend && python main.py

### Frontend起動  
cd frontend && flutter run

### pubspec.yamlに書かれているパッケージをインストール
cd frontend
flutter clean
flutter pub get

### バックエンドの依存関係をインストール
cd ../
pip install -r requirements.txt