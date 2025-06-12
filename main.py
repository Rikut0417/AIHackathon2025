import os
import sys
import json
import io
import fitz  # PyMuPDF

# Google Cloud & Firebase
import firebase_admin
from firebase_admin import firestore
import google.auth
from googleapiclient.discovery import build

# Vertex AI (Gemini)
import vertexai
from vertexai.generative_models import GenerativeModel
import functions_framework

# --- アプリケーションの初期化 ---

# Firebaseアプリを初期化
firebase_admin.initialize_app()

# GCP環境変数を取得
PROJECT_ID = os.environ.get("GCP_PROJECT")
LOCATION = "asia-northeast1"  # 必要に応じて変更

# Vertex AIとFirestoreクライアントを初期化
vertexai.init(project=PROJECT_ID, location=LOCATION)
db = firestore.client()


def get_drive_service():
    """サービスアカウント認証を使用し、Drive APIのサービスオブジェクトを生成する"""
    creds, _ = google.auth.default(scopes=["https://www.googleapis.com/auth/drive.readonly"])
    return build("drive", "v3", credentials=creds, cache_discovery=False)

def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """PDFのバイトデータからテキストを抽出する"""
    text = ""
    with fitz.open(stream=pdf_bytes, filetype="pdf") as doc:
        for page in doc:
            text += page.get_text()
    return text

@functions_framework.cloud_event
def process_drive_upload(cloudevent):
    """
    Google DriveへのPDFアップロードをトリガーに実行されるCloud Function
    """
    try:
        # 1. トリガーイベントからファイル情報を取得
        payload = cloudevent.data.get("protoPayload", {})
        file_info = payload.get("response", {})
        file_id = file_info.get("id")
        file_name = file_info.get("name")

        # 2. 対象ファイルかどうかの判定
        if file_name != "自己紹介.pdf":
            return "Target file not found, skipping.", 200

        # 3. PDFのダウンロードとテキスト抽出
        drive_service = get_drive_service()
        request = drive_service.files().get_media(fileId=file_id)
        file_stream = io.BytesIO()
        request.execute(fh=file_stream)

        extracted_text = extract_text_from_pdf(file_stream.getvalue())
        if not extracted_text:
            return "PDF content is empty.", 200

        # 4. Gemini APIで情報をJSONとして抽出
        model = GenerativeModel("gemini-1.5-pro-001")
        prompt = f"""
        以下の自己紹介文から、「名前」と「趣味」の情報を抽出し、
        "name"と"hobby"をキーに持つJSONオブジェクトの配列（リスト）として、
        JSON文字列のみを出力してください。他の説明は不要です。

        --- 自己紹介文 ---
        {extracted_text}
        --- 自己紹介文終わり ---
        """

        response = model.generate_content(prompt)
        json_string = response.text.strip().lstrip("```json").rstrip("```")
        extracted_data = json.loads(json_string)

        # 5. Firestoreにデータを登録
        collection_ref = db.collection("profiles")
        if isinstance(extracted_data, list):
            for item in extracted_data:
                collection_ref.add(item)
        else:
            collection_ref.add(extracted_data)

        return "Processing complete.", 200

    except Exception as e:
        # エラー発生時はログに記録して終了
        sys.stderr.write(f"An error occurred: {e}\n")
        return "An error occurred.", 500
