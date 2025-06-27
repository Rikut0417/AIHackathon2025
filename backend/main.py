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
            return jsonify({
                'success': False,
                'error': 'Request data is required'
            }), 400

        search_hobby = data.get('hobby', '').strip()
        search_birthplace = data.get('birthplace', '').strip()
        collection_name = 'profiles'

        # 両方とも空の場合はエラー
        if not search_hobby and not search_birthplace:
            return jsonify({
                'success': False,
                'error': '趣味または出身地のいずれかを入力してください'
            }), 400

        print(f"'{collection_name}'コレクションから検索します...")
        if search_hobby:
            print(f"  - 趣味: 「{search_hobby}」")
        if search_birthplace:
            print(f"  - 出身地: 「{search_birthplace}」")

        found_users = []
        processed_user_ids = set()  # 重複を避けるため

        # 1. 趣味での検索（趣味が指定されている場合）
        if search_hobby:
            print(f"趣味「{search_hobby}」で検索中...")
            hobby_query = db.collection(collection_name).where(
                filter=FieldFilter('hobby', 'array_contains', search_hobby)
            )
            hobby_docs = hobby_query.stream()

            for doc in hobby_docs:
                if doc.id in processed_user_ids:
                    continue

                profile_data = doc.to_dict()
                user_birthplace = profile_data.get('birthplace', '不明')

                # 出身地の条件もチェック（指定されている場合）
                birthplace_match = not search_birthplace or search_birthplace in user_birthplace

                if birthplace_match:
                    hobby_list = profile_data.get('hobby', [])
                    hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)

                    found_users.append({
                        "name": profile_data.get('name', '名前なし'),
                        "name_roman": profile_data.get('name_roman', 'Unknown Name'),
                        "hobby": hobby_string,
                        "birthplace": user_birthplace,
                        "department": profile_data.get('department', '部署不明'),
                        "matched_hobby": search_hobby,
                        "matched_birthplace": search_birthplace if search_birthplace and search_birthplace in user_birthplace else None,
                        "match_type": "hobby" + ("_and_birthplace" if search_birthplace and search_birthplace in user_birthplace else "")
                    })
                    processed_user_ids.add(doc.id)

        # 2. 出身地での検索（出身地が指定されており、趣味のみの検索で見つからなかった場合）
        if search_birthplace:
            print(f"出身地「{search_birthplace}」で検索中...")
            # 全てのドキュメントを取得して出身地をチェック
            all_docs = db.collection(collection_name).stream()

            for doc in all_docs:
                if doc.id in processed_user_ids:
                    continue

                profile_data = doc.to_dict()
                user_birthplace = profile_data.get('birthplace', '')

                # 出身地にマッチするかチェック
                if search_birthplace in user_birthplace:
                    # 趣味の条件もチェック（指定されている場合）
                    hobby_match = True
                    if search_hobby:
                        hobby_list = profile_data.get('hobby', [])
                        hobby_match = search_hobby in hobby_list

                    if hobby_match:
                        hobby_list = profile_data.get('hobby', [])
                        hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)

                        found_users.append({
                            "name": profile_data.get('name', '名前なし'),
                            "name_roman": profile_data.get('name_roman', 'Unknown Name'),
                            "hobby": hobby_string,
                            "birthplace": user_birthplace,
                            "department": profile_data.get('department', '部署不明'),
                            "matched_hobby": search_hobby if search_hobby and search_hobby in hobby_list else None,
                            "matched_birthplace": search_birthplace,
                            "match_type": "birthplace" + ("_and_hobby" if search_hobby and search_hobby in hobby_list else "")
                        })
                        processed_user_ids.add(doc.id)

        print(f"{len(found_users)}件見つかりました。")

        return jsonify({
            'success': True,
            'users': found_users,
            'count': len(found_users),
            'search_conditions': {
                'hobby': search_hobby,
                'birthplace': search_birthplace
            }
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
