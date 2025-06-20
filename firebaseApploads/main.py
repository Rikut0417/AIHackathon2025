import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

# --- 初期化処理 ---
# 1. サービスアカウントキーのJSONファイルへのパスを指定
#    ダウンロードした秘密鍵のファイル名を指定してください
cred = credentials.Certificate("C:/Users/rina_ishida/Downloads/AIhackathon2025-serviceAccountKey.json")

# 2. Firebaseプロジェクトの初期化
#    'databaseURL'は、FirebaseコンソールのRealtime DatabaseのURLを指定します。
#    (例: https://<YOUR-PROJECT-ID>-default-rtdb.firebaseio.com/)
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://engineeringu-default-rtdb.firebaseio.com/'
})


# --- データ参照処理 ---

# データベースのルート（一番上の階層）を参照
ref = db.reference('/')

# ルート直下の全データを取得
# .get()メソッドでデータをPythonの辞書（dict）やリスト（list）として取得できます
all_data = ref.get()
print("--- 全データ ---")
print(all_data)
print("\n")


# 特定のパス ('/users') を参照
users_ref = db.reference('/users')

# '/users' 以下のデータを取得
users_data = users_ref.get()
print("--- ユーザーデータ一覧 ---")
print(users_data)
print("\n")


# さらに深い階層 ('/users/user01') を参照
user01_ref = db.reference('/users/user01')

# '/users/user01' のデータを取得
user01_data = user01_ref.get()
print("--- user01 のデータ ---")
print(user01_data)

# 取得したデータは通常のPython辞書として扱えます
print(f"名前: {user01_data['name']}")
print(f"年齢: {user01_data['age']}")
print(f"スキル: {', '.join(user01_data['skills'])}")
