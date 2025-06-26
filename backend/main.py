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
        if not data:
            return jsonify({'success': False, 'error': 'Request data is required'}), 400

        search_hobby = data.get('hobby', '').strip()
        search_birthplace = data.get('birthplace', '').strip()

        if not search_hobby and not search_birthplace:
            return jsonify({'success': False, 'error': '趣味または出身地のいずれかを入力してください'}), 400

        collection_name = 'profiles'
        query = db.collection(collection_name)

        if search_hobby:
            print(f"条件追加: 趣味に「{search_hobby}」を含む")
            query = query.where(filter=FieldFilter('hobby', 'array_contains', search_hobby))

        if search_birthplace:
            print(f"条件追加: 出身地が「{search_birthplace}」と一致")
            query = query.where(filter=FieldFilter('birthplace', '==', search_birthplace))

        docs = query.stream()

        found_users = []
        for doc in docs:
            profile_data = doc.to_dict()
            hobby_list = profile_data.get('hobby', [])
            hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)

            found_users.append({
                "name": profile_data.get('name', '名前なし'),
                "hobby": hobby_string,
                "birthplace": profile_data.get('birthplace', '不明'),
                "department": profile_data.get('department', '部署不明'),
            })

        print(f"{len(found_users)}件見つかりました。")

        return jsonify({
            'success': True,
            'users': found_users,
            'count': len(found_users)
        })

    except Exception as e:
        print(f"データ取得中にエラーが発生しました: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
