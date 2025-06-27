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
    # 環境変数からサービスアカウントキーのファイルパスを取得
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
    if not service_account_path:
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_KEY環境変数が設定されていません")

    cred = credentials.Certificate(service_account_path)

    # アプリがまだ初期化されていなければ初期化
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)

    print("Firebaseへの接続準備ができました。")

except Exception as e:
    print(f"Firebaseの初期化中にエラーが発生しました: {e}")
    exit()

db = firestore.client()

@app.route('/search', methods=['POST'])
def search_users():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Request data is required'}), 400

        # リクエストから検索キーワードを取得
        search_hobby = data.get('hobby', '').strip()
        search_birthplace = data.get('birthplace', '').strip()

        if not search_hobby and not search_birthplace:
            return jsonify({'success': False, 'error': '趣味または出身地のいずれかを入力してください'}), 400

        collection_name = 'profiles'
        query = db.collection(collection_name)

        # --- 効率的なAND検索クエリの構築 ---
        # 趣味が指定されていれば、hobby_keywordsに対する検索条件を追加
        if search_hobby:
            print(f"条件追加: 趣味キーワードに「{search_hobby}」を含む")
            query = query.where(filter=FieldFilter('hobby_keywords', 'array_contains', search_hobby))

        # 出身地が指定されていれば、birthplace_keywordsに対する検索条件を追加
        if search_birthplace:
            print(f"条件追加: 出身地キーワードに「{search_birthplace}」を含む")
            query = query.where(filter=FieldFilter('birthplace_keywords', 'array_contains', search_birthplace))

        # 組み立てたクエリをFirestoreで実行
        docs = query.stream()

        found_users = []
        # --- ヒットしたユーザーの情報を整形 ---
        for doc in docs:
            profile_data = doc.to_dict()

            # 趣味リストをカンマ区切りの文字列に変換
            hobby_list = profile_data.get('hobby', [])
            hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)

            # マッチ種別を判定
            match_type = ""
            if search_hobby and search_birthplace:
                match_type = "hobby_and_birthplace"
            elif search_hobby:
                match_type = "hobby"
            elif search_birthplace:
                match_type = "birthplace"

            # ご要望のあった詳細情報を含む形式でユーザー情報をリストに追加
            found_users.append({
                "name": profile_data.get('name', '名前なし'),
                "name_roman": profile_data.get('name_roman', 'Unknown Name'),
                "hobby": hobby_string,
                "birthplace": profile_data.get('birthplace', '不明'),
                "department": profile_data.get('department', '部署不明'),
                "matched_hobby": search_hobby if search_hobby else None,
                "matched_birthplace": search_birthplace if search_birthplace else None,
                "match_type": match_type
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