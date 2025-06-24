from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin.firestore import FieldFilter

import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

try:
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
    if not service_account_path:
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_KEY環境変数が設定されていません")

    cred = credentials.Certificate(service_account_path)

    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    print("Firebaseへの接続準備ができました。")
except Exception as e:
    print(f"初期化中にエラーが発生しました: {e}")
    exit()

db = firestore.client()

@app.route('/search', methods=['POST'])
def search_users():
    try:
        data = request.get_json()

        if not data or 'hobby' not in data:
            return jsonify({
                'success': False,
                'error': 'hobby parameter is required'
            }), 400

        search_keyword = data['hobby']
        collection_name = 'profiles'

        print(f"'{collection_name}'コレクションから趣味に「{search_keyword}」を含むユーザーを検索します...")

        found_users = []

        query = db.collection(collection_name).where(
            filter=FieldFilter('hobby', 'array_contains', search_keyword)
        )
        found_docs_stream = query.stream()

        for doc in found_docs_stream:
            profile_data = doc.to_dict()
            found_users.append({
                "name": profile_data.get('name', '名前なし'),
                "hobby": profile_data.get('hobby', []),
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