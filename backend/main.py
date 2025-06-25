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

        search_hobby = data['hobby']
        search_birthplace = data.get('birthplace', '')
        collection_name = 'profiles'

        found_users = []

        # 両方の条件が入力されている場合はAND検索（両方一致）
        if search_hobby and search_birthplace:
            print(f"'{collection_name}'コレクションから趣味に「{search_hobby}」を含み、かつ出身地に「{search_birthplace}」を含むユーザーを検索します...")
            
            # 趣味で検索してから出身地でフィルタリング
            hobby_query = db.collection(collection_name).where(
                filter=FieldFilter('hobby', 'array_contains', search_hobby)
            )
            hobby_docs = hobby_query.stream()

            for doc in hobby_docs:
                profile_data = doc.to_dict()
                user_birthplace = profile_data.get('birthplace', '不明')
                
                # 出身地の条件もチェック（AND条件）
                if search_birthplace in user_birthplace:
                    # 趣味の配列を文字列に変換
                    hobby_list = profile_data.get('hobby', [])
                    hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)
                    
                    found_users.append({
                        "name": profile_data.get('name', '名前なし'),
                        "hobby": hobby_string,
                        "birthplace": user_birthplace,
                        "department": profile_data.get('department', '部署不明'),
                        "matched_hobby": search_hobby,
                        "matched_birthplace": search_birthplace
                    })

        # 趣味のみが入力されている場合
        elif search_hobby and not search_birthplace:
            print(f"'{collection_name}'コレクションから趣味に「{search_hobby}」を含むユーザーを検索します...")
            
            hobby_query = db.collection(collection_name).where(
                filter=FieldFilter('hobby', 'array_contains', search_hobby)
            )
            hobby_docs = hobby_query.stream()

            for doc in hobby_docs:
                profile_data = doc.to_dict()
                user_birthplace = profile_data.get('birthplace', '不明')
                
                # 趣味の配列を文字列に変換
                hobby_list = profile_data.get('hobby', [])
                hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)
                
                found_users.append({
                    "name": profile_data.get('name', '名前なし'),
                    "hobby": hobby_string,
                    "birthplace": user_birthplace,
                    "department": profile_data.get('department', '部署不明'),
                    "matched_hobby": search_hobby,
                    "matched_birthplace": None
                })

        # 出身地のみが入力されている場合
        elif not search_hobby and search_birthplace:
            print(f"'{collection_name}'コレクションから出身地に「{search_birthplace}」を含むユーザーを検索します...")
            
            all_docs = db.collection(collection_name).stream()
            
            for doc in all_docs:
                profile_data = doc.to_dict()
                user_birthplace = profile_data.get('birthplace', '不明')
                
                if search_birthplace in user_birthplace:
                    # 趣味の配列を文字列に変換
                    hobby_list = profile_data.get('hobby', [])
                    hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)
                    
                    found_users.append({
                        "name": profile_data.get('name', '名前なし'),
                        "hobby": hobby_string,
                        "birthplace": user_birthplace,
                        "department": profile_data.get('department', '部署不明'),
                        "matched_hobby": None,
                        "matched_birthplace": search_birthplace
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