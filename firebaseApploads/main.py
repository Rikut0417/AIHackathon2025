from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os
from dotenv import load_dotenv

# .envファイルを読み込み
load_dotenv()

app = Flask(__name__)
CORS(app)  # CORS を有効にする

# --- 初期化処理 ---
# Firebaseプロジェクトの初期化
try:
    # 環境変数から秘密鍵のパスを取得
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
    if not service_account_path:
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_KEY環境変数が設定されていません")
    
    cred = credentials.Certificate(service_account_path)
    # アプリが既に初期化されていないかチェック
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    print("Firebaseへの接続準備ができました。")
except Exception as e:
    print(f"初期化中にエラーが発生しました: {e}")
    # 初期化に失敗したら、ここで処理を中断
    exit()

db = firestore.client()

@app.route('/search', methods=['POST'])
def search_users():
    try:
        # リクエストからJSONデータを取得
        data = request.get_json()
        
        if not data or 'hobby' not in data:
            return jsonify({
                'success': False,
                'error': 'hobby parameter is required'
            }), 400
        
        search_keyword = data['hobby']
        collection_name = 'profiles'
        
        print(f"'{collection_name}'コレクションから「{search_keyword}」を趣味に含むユーザーを検索します...")
        
        # 条件に一致したユーザーを格納するための空のリスト
        found_users = []
        
        # コレクションの全ドキュメントを取得
        all_profiles_stream = db.collection(collection_name).stream()
        
        # ループで1件ずつデータをチェック
        for doc in all_profiles_stream:
            profile_data = doc.to_dict()
            
            # hobbyフィールドの存在、型、キーワードの含有をチェックします
            if 'hobby' in profile_data and isinstance(profile_data['hobby'], str) and search_keyword in profile_data['hobby']:
                # 条件に合致したら、結果リストに追加
                found_users.append({
                    "name": profile_data.get('name', '名前なし'),
                    "hobby": profile_data.get('hobby', ''),
                    "birthplace": profile_data.get('birthplace', '不明'),
                    "department": profile_data.get('department', '部署不明')
                })
        
        print(f"{len(found_users)}件見つかりました。")
        
        return jsonify({
            'success': True,
            'users': found_users,
            'count': len(found_users)
        })
        
    except Exception as e:
        print(f"データ取得中にエラーが発生しました: {e}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
