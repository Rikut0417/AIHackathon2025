import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os

# --- 初期化処理 ---
CRED_FILE = "AIhackathon2025-serviceAccountKey.json"
# Firebaseプロジェクトの初期化
try:
    # ファイルの存在をチェック
    if not os.path.exists(CRED_FILE):
        raise FileNotFoundError

    cred = credentials.Certificate(CRED_FILE)
    # アプリが既に初期化されていないかチェック
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    print("Firebaseへの接続準備ができました。")

except FileNotFoundError:
    print(f"エラー: 秘密鍵ファイル '{CRED_FILE}' が見つかりません。")
    print("このスクリプトと同じ階層に、管理者から共有された秘密鍵ファイルを配置してください。")
    exit() # 処理を中断

except Exception as e:
    print(f"初期化中にエラーが発生しました: {e}")
    # 初期化に失敗したら、ここで処理を中断
    exit()

db = firestore.client()

# --- データ参照処理 ---

# 'profiles'コレクションから特定のIDのデータを取得
collection_name = 'profiles'
search_keyword = '旅行'

print(f"'{collection_name}'コレクションから「{search_keyword}」を趣味に含むユーザーを検索します...")

# 条件に一致したユーザーを格納するための空のリスト
found_users = []

try:
    # コレクションの全ドキュメントを取得
    all_profiles_stream = db.collection(collection_name).stream()

    # ループで1件ずつデータをチェック
    for doc in all_profiles_stream:
        profile_data = doc.to_dict()

        # hobbyフィールドの存在、型、キーワードの含有をチェックします
        if 'hobby' in profile_data and isinstance(profile_data['hobby'], str) and search_keyword in profile_data['hobby']:
            # 条件に合致したら、結果リストに追加
            found_users.append({
                "id": doc.id,
                "data": profile_data
            })

    # --- ステップ3: 結果の表示 ---
    print("\n--- 検索結果 ---")
    if found_users:
        print(f"{len(found_users)}件見つかりました。")
        for user in found_users:
            user_name = user['data'].get('name', '名前なし')
            user_hobby = user['data'].get('hobby', '')
            print(f"  - ID: {user['id']}, 名前: {user_name}, 趣味: {user_hobby}")
    else:
        print("条件に合うユーザーは見つかりませんでした。")

except Exception as e:
    print(f"データ取得中にエラーが発生しました: {e}")
