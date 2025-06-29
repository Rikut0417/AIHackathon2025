from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin.firestore import FieldFilter
import google.generativeai as genai
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
import io
import tempfile

import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

# Gemini APIの設定
genai.configure(api_key=os.getenv('GEMINI_API_KEY', 'AIzaSyA76JE40QbT8NHvynBsFSIgD_Nzk1zOqog'))

try:
    # 環境変数からサービスアカウントキーのファイルパスを取得
    service_account_path = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
    
    if service_account_path and os.path.exists(service_account_path):
        cred = credentials.Certificate(service_account_path)
    else:
        # Cloud Runの場合、デフォルト認証を使用
        cred = credentials.ApplicationDefault()

    # アプリがまだ初期化されていなければ初期化
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)

    print("Firebaseへの接続準備ができました。")

except Exception as e:
    print(f"Firebaseの初期化中にエラーが発生しました: {e}")
    # 開発時はexit()するが、本番では継続
    if os.getenv('FLASK_ENV') == 'development':
        exit()
    else:
        print("本番環境のため、継続します")

db = firestore.client()

# 地域同義語マッピング辞書（関西・近畿地方のみ）
REGION_SYNONYMS = {
    # 関西・近畿地方
    '関西': ['大阪府', '京都府', '兵庫県', '奈良県', '滋賀県', '和歌山県'],
    '近畿': ['大阪府', '京都府', '兵庫県', '奈良県', '滋賀県', '和歌山県'],
    '関西地方': ['大阪府', '京都府', '兵庫県', '奈良県', '滋賀県', '和歌山県'],
    '近畿地方': ['大阪府', '京都府', '兵庫県', '奈良県', '滋賀県', '和歌山県'],
}

def expand_search_terms(search_term):
    """検索キーワードを同義語で展開する"""
    if not search_term:
        return []
    
    # 元の検索語を含める
    expanded_terms = [search_term]
    
    # 同義語辞書で展開
    for synonym, regions in REGION_SYNONYMS.items():
        if search_term in synonym or synonym in search_term:
            expanded_terms.extend(regions)
    
    # 重複を除去して返す
    return list(set(expanded_terms))

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

        # --- 部分一致検索のための全データ取得とアプリケーション側フィルタリング ---
        found_users = []
        
        # 同義語展開情報を記録
        expanded_hobby_terms = expand_search_terms(search_hobby) if search_hobby else []
        expanded_birthplace_terms = expand_search_terms(search_birthplace) if search_birthplace else []
        
        print(f"部分一致検索を実行: 趣味='{search_hobby}', 出身地='{search_birthplace}'")
        if expanded_hobby_terms and len(expanded_hobby_terms) > 1:
            print(f"趣味同義語展開: {expanded_hobby_terms}")
        if expanded_birthplace_terms and len(expanded_birthplace_terms) > 1:
            print(f"出身地同義語展開: {expanded_birthplace_terms}")
        
        # 全ユーザーデータを取得
        docs = query.stream()
        
        def matches_hobby(profile_data, search_term):
            """趣味の部分一致判定とマッチした単語を返す"""
            if not search_term:
                return True, []
            
            matched_words = []
            
            # hobby_keywords配列内の要素で部分一致チェック
            hobby_keywords = profile_data.get('hobby_keywords', [])
            for keyword in hobby_keywords:
                if search_term in keyword:
                    matched_words.append(keyword)
            
            # hobby配列内の要素でも部分一致チェック
            hobby_list = profile_data.get('hobby', [])
            for hobby in hobby_list:
                if search_term in hobby:
                    matched_words.append(hobby)
            
            # 重複を除去
            matched_words = list(set(matched_words))
            
            return len(matched_words) > 0, matched_words
        
        def matches_birthplace(profile_data, search_term):
            """出身地の部分一致判定とマッチした単語を返す（同義語展開対応）"""
            if not search_term:
                return True, []
            
            matched_words = []
            
            # 検索語を同義語で展開
            expanded_terms = expand_search_terms(search_term)
            
            # birthplace_keywords配列内の要素で部分一致チェック
            birthplace_keywords = profile_data.get('birthplace_keywords', [])
            for keyword in birthplace_keywords:
                # 元の検索語での一致
                if search_term in keyword:
                    matched_words.append(keyword)
                # 展開された同義語での一致
                for expanded_term in expanded_terms:
                    if expanded_term in keyword:
                        matched_words.append(keyword)
            
            # birthplace文字列でも部分一致チェック
            birthplace = profile_data.get('birthplace', '')
            # 元の検索語での一致
            if search_term in birthplace:
                matched_words.append(birthplace)
            # 展開された同義語での一致
            for expanded_term in expanded_terms:
                if expanded_term in birthplace:
                    matched_words.append(birthplace)
            
            # 重複を除去
            matched_words = list(set(matched_words))
            
            return len(matched_words) > 0, matched_words
        
        # 各ユーザーをフィルタリング
        for doc in docs:
            profile_data = doc.to_dict()
            
            hobby_match, hobby_matched_words = matches_hobby(profile_data, search_hobby)
            birthplace_match, birthplace_matched_words = matches_birthplace(profile_data, search_birthplace)
            
            # 指定された条件に基づくマッチング判定
            is_match = False
            match_type = ""
            
            if search_hobby and search_birthplace:
                # 両方指定：両方にマッチする必要あり
                if hobby_match and birthplace_match:
                    is_match = True
                    match_type = "hobby_and_birthplace"
            elif search_hobby:
                # 趣味のみ指定
                if hobby_match:
                    is_match = True
                    match_type = "hobby"
            elif search_birthplace:
                # 出身地のみ指定
                if birthplace_match:
                    is_match = True
                    match_type = "birthplace"
            
            if is_match:
                # 趣味リストをカンマ区切りの文字列に変換
                hobby_list = profile_data.get('hobby', [])
                hobby_string = ', '.join(hobby_list) if isinstance(hobby_list, list) else str(hobby_list)

                found_users.append({
                    "name": profile_data.get('name', '名前なし'),
                    "name_roman": profile_data.get('name_roman', 'Unknown Name'),
                    "hobby": hobby_string,
                    "birthplace": profile_data.get('birthplace', '不明'),
                    "department": profile_data.get('department', '部署不明'),
                    "matched_hobby": search_hobby if search_hobby else None,
                    "matched_birthplace": search_birthplace if search_birthplace else None,
                    "matched_hobby_words": hobby_matched_words,
                    "matched_birthplace_words": birthplace_matched_words,
                    "match_type": match_type
                })

        print(f"{len(found_users)}件見つかりました。")

        return jsonify({
            'success': True,
            'users': found_users,
            'count': len(found_users),
            'search_info': {
                'original_hobby': search_hobby,
                'original_birthplace': search_birthplace,
                'expanded_hobby_terms': expanded_hobby_terms,
                'expanded_birthplace_terms': expanded_birthplace_terms
            }
        })

    except Exception as e:
        print(f"データ取得中にエラーが発生しました: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'})

@app.route('/generate-booklet', methods=['POST'])
def generate_booklet():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'success': False, 'error': 'Request data is required'}), 400

        hobby = data.get('hobby', '').strip()
        birthplace = data.get('birthplace', '').strip()

        if not hobby and not birthplace:
            return jsonify({'success': False, 'error': '趣味または出身地のいずれかを入力してください'}), 400

        # Gemini APIでしおり内容を生成
        content = generate_booklet_content(hobby, birthplace)
        
        # TXTファイルを生成
        temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.txt', mode='w', encoding='utf-8')
        temp_file.write(content)
        temp_file.close()
        
        # ファイル名を生成
        if hobby and birthplace:
            filename = f"{birthplace}人{hobby}サークル_しおり.txt"
        elif hobby:
            filename = f"{hobby}サークル_しおり.txt"
        else:
            filename = f"{birthplace}ふるさと会_しおり.txt"
        
        return send_file(
            temp_file.name,
            as_attachment=True,
            download_name=filename,
            mimetype='text/plain; charset=utf-8'
        )

    except Exception as e:
        print(f"しおり生成中にエラーが発生しました: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500

def generate_booklet_content(hobby, birthplace):
    """Gemini APIを使ってしおり内容を生成"""
    try:
        print(f"Gemini API呼び出し開始: hobby={hobby}, birthplace={birthplace}")
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        if hobby and birthplace:
            prompt = f"""
あなたはサークル活動のプロデューサーです。趣味「{hobby}」と出身地「{birthplace}」を活かした魅力的なサークル活動のしおりを作成してください。

以下の構成で、具体的で実行しやすい内容を作成してください：

# 【サークル名】
{hobby}と{birthplace}を組み合わせたキャッチーな名前を考案

## 🎯 活動目標
- {hobby}を通じて{birthplace}出身者同士の絆を深める
- 具体的で魅力的な目標を3つ

## 🚀 キックオフミーティング
- 開催場所：{birthplace}らしい場所の提案
- 具体的な内容とタイムスケジュール
- 必要な準備物

## 📅 月間活動プラン
1. **第1週**: {hobby}の基本活動 + {birthplace}文化要素
2. **第2週**: スキルアップ企画
3. **第3週**: 交流イベント
4. **第4週**: 特別企画・発表会

## 🤝 メンバー交流アイデア
- {birthplace}の名物を使った交流企画
- {hobby}を通じた協力ゲーム
- 故郷トークセッション

## 🎪 特別イベント案
- 年間3つの大型イベント提案
- {birthplace}の季節行事と連動

## 🔮 1年後のビジョン
メンバーが達成感を感じる具体的な成果目標

すべて実行可能で魅力的な内容にしてください！
"""
        elif hobby:
            prompt = f"""
あなたはサークル活動のプロデューサーです。趣味「{hobby}」の魅力的なサークル活動しおりを作成してください。

# 【{hobby}サークル】

## 🎯 活動目標
- {hobby}の技術向上と楽しさの共有
- 初心者から上級者まで楽しめる環境作り
- 長期的な仲間づくり

## 🚀 初回ミーティング
- アイスブレイク企画
- {hobby}体験セッション
- レベル別グループ分け
- 今後の活動計画相談

## 📅 月間活動プラン
1. **基礎練習週**: 技術向上セッション
2. **応用練習週**: 実践的な活動
3. **交流週**: ゲームや競技会
4. **発表週**: 成果共有・振り返り

## 🤝 交流促進アイデア
- バディシステム（先輩・後輩ペア）
- スキル交換セッション
- {hobby}以外の趣味共有タイム

## 🎪 年間イベント
- 春：新人歓迎大会
- 夏：{hobby}合宿・大会
- 秋：文化祭参加
- 冬：忘年会・総会

## 🔮 目指すゴール
1年後には全員が{hobby}の楽しさを人に伝えられるレベルに！
"""
        else:  # birthplace only
            prompt = f"""
あなたはコミュニティオーガナイザーです。出身地「{birthplace}」の人たちが集まる温かいコミュニティしおりを作成してください。

# 【{birthplace}ふるさと会】

## 🎯 活動目標
- {birthplace}出身者同士の絆づくり
- 故郷の文化・思い出の共有
- 新しい土地での支え合い

## 🚀 初回集会
- 場所：{birthplace}料理が食べられるお店
- 自己紹介＋故郷エピソード
- {birthplace}クイズ大会
- 今後の活動アイデア出し

## 📅 月間活動プラン
1. **グルメ週**: {birthplace}の名物料理を味わう
2. **文化週**: {birthplace}の伝統・歴史を学ぶ
3. **交流週**: メンバー同士の親睦を深める
4. **企画週**: {birthplace}への帰省報告・計画

## 🤝 絆を深めるアイデア
- {birthplace}の方言で話す時間
- 故郷の写真・お土産持ち寄り
- {birthplace}あるあるトーク
- 帰省土産の交換会

## 🎪 年間特別企画
- {birthplace}の祭りを再現
- 故郷ツアー企画
- {birthplace}出身有名人トーク
- 年末故郷自慢大会

## 🔮 コミュニティビジョン
{birthplace}を離れても、いつでも故郷を感じられる第二の家族のような場所に！
"""
        
        print(f"プロンプト送信中...")
        response = model.generate_content(prompt)
        print(f"Gemini API応答成功: {len(response.text)}文字")
        return response.text
        
    except Exception as e:
        print(f"Gemini API呼び出しエラー詳細: {type(e).__name__}: {e}")
        # より詳細なフォールバック用のテンプレート
        return generate_enhanced_fallback_content(hobby, birthplace)

def generate_enhanced_fallback_content(hobby, birthplace):
    """APIエラー時の改善されたフォールバック内容"""
    if hobby and birthplace:
        # 趣味と出身地両方の場合：地域特化型サークル
        title = f"{birthplace}人{hobby}サークル"
        content = f"""
# 🌟 {title} 活動しおり

## 🎯 活動目標
- {birthplace}出身の{hobby}愛好者同士の絆を深める
- 故郷{birthplace}ならではの{hobby}の楽しみ方を発見する
- {birthplace}の文化と{hobby}を融合した新しい体験を創造する

## 🚀 キックオフミーティング
**日時**: 毎月第1土曜日 14:00-17:00
**場所**: {birthplace}料理店の個室 または {hobby}ができる会場

### プログラム
- 14:00-14:30: {birthplace}弁での自己紹介タイム
- 14:30-15:30: {hobby} × {birthplace}文化の融合体験
- 15:30-16:00: {birthplace}の懐かしい話と{hobby}エピソード
- 16:00-17:00: {birthplace}らしい{hobby}活動プラン相談

## 📅 月間活動スケジュール
### 第1週: {birthplace}流{hobby}基礎編
- {hobby}の基本を{birthplace}の伝統と合わせて学ぶ
- {birthplace}名物と一緒に{hobby}を楽しむ

### 第2週: 故郷スタイル応用編
- {birthplace}独特の{hobby}アプローチを体験
- 地元の有名な{hobby}スポットや人物について学ぶ

### 第3週: 交流・協力編
- {hobby}を通じた{birthplace}人同士のチームワーク
- 故郷への愛を込めた{hobby}プロジェクト

### 第4週: 発表・祭り編
- {birthplace}風{hobby}発表会
- {birthplace}の季節料理と{hobby}成果の共有

## 🤝 {birthplace}ならではの交流
- **方言{hobby}タイム**: {birthplace}弁で{hobby}を教え合う
- **故郷{hobby}自慢大会**: {birthplace}で体験した{hobby}話を披露
- **{birthplace}×{hobby}探検隊**: 地元風{hobby}スポットを発見
- **帰省{hobby}計画**: みんなで{birthplace}帰省時の{hobby}活動を企画

## 🎪 年間特別企画
- **春**: {birthplace}の桜と{hobby}フェスティバル
- **夏**: {hobby}で楽しむ{birthplace}夏祭り再現
- **秋**: {birthplace}の紅葉{hobby}合宿
- **冬**: 故郷の年越し{hobby}イベント

## 🔮 1年後のビジョン
{birthplace}を離れていても、いつでも故郷の心と{hobby}の情熱を分かち合える場所。
{birthplace}出身の{hobby}愛好者として、故郷に誇れる活動を続けていく。

---
💝 {birthplace}の心と{hobby}の楽しさで、最高の仲間を見つけましょう！
"""
    elif hobby:
        content = f"""
# ⭐ {hobby}愛好会 活動しおり

## 🎯 活動目標
- {hobby}の技術向上と深い楽しさの発見
- 初心者から上級者まで全員が成長できる環境づくり
- {hobby}を通じた一生の友達づくり

## 🚀 初回ミーティング
### アイスブレイク（30分）
- {hobby}との出会いエピソード共有
- 今の{hobby}レベルと目標設定
- ニックネーム決め

### {hobby}体験セッション（60分）
- みんなで基本を楽しく練習
- 上級者が初心者をサポート
- グループ分けとバディ決め

### 今後の計画相談（30分）
- みんなでやりたいことリストアップ
- 月間スケジュール相談
- 役割分担決め

## 📅 充実の月間プログラム
### 🔰 第1週: 基礎力アップ週
- 技術の基本をしっかり練習
- 先輩から後輩へのコツ伝授
- 個人目標の設定と確認

### 🌟 第2週: 応用・挑戦週
- 新しい技術やスタイルに挑戦
- グループワークでスキル向上
- 外部講師やプロから学ぶ機会

### 🎉 第3週: 交流・ゲーム週
- {hobby}を使った楽しいゲーム大会
- 他のサークルとの交流試合
- メンバー同士の親睦を深める企画

### 📢 第4週: 発表・振り返り週
- 月間の成果をみんなで発表
- 改善点と次月の目標設定
- お疲れ様会で絆を深める

## 🤝 みんなでつながる仕組み
- **バディシステム**: 先輩・後輩が1対1でサポート
- **スキル交換会**: 得意分野をお互いに教え合う
- **{hobby}日記**: 練習記録をみんなでシェア
- **月1回ランチ会**: {hobby}以外の話も楽しむ

## 🎪 1年間の特別イベント
- **春の新人歓迎大会**: みんなで{hobby}を楽しく紹介
- **夏の{hobby}合宿**: 集中練習＋BBQ＋花火
- **秋の成果発表会**: 家族・友人を招いて披露
- **冬の忘年会**: 1年の成長をみんなで祝う

## 🔮 みんなで目指すゴール
1年後には全員が「{hobby}って本当に楽しい！」と心から言えて、
新しく始める人に優しく教えられるようになること。
{hobby}を通じて出会った仲間との絆が一生の宝物になること。

---
🌈 一緒に{hobby}の世界を探検して、最高の仲間を見つけましょう！
"""
    else:  # birthplace only
        content = f"""
# 🏡 {birthplace}ふるさと会 活動しおり

## 🎯 活動目標
- {birthplace}出身者同士の心温まるつながりづくり
- 故郷の文化・思い出・愛を分かち合う
- 新しい土地でも{birthplace}の心を大切に

## 🚀 初回ふるさと集会
### 故郷で乾杯！（30分）
- {birthplace}の好きな場所・思い出話
- 懐かしい方言で自己紹介
- 故郷のソウルフード談義

### {birthplace}クイズ大会（45分）
- 地元あるある問題
- 隠れた名所紹介
- 有名人・グルメ・文化クイズ

### みんなで企画会議（45分）
- やりたいイベントのアイデア出し
- 故郷との関わり方を相談
- 役割分担と連絡方法決め

## 📅 月間故郷体験プログラム
### 🍴 第1週: グルメ週
- {birthplace}名物料理の持ち寄り＆試食会
- 地元の隠れた名店情報交換
- みんなで{birthplace}料理作り

### 📚 第2週: 文化・歴史週
- {birthplace}の歴史や文化を学ぶ
- 方言講座で懐かしい言葉を復習
- 伝統的な遊びや歌を楽しむ

### 🤝 第3週: 交流・親睦週
- メンバー同士の深い話タイム
- 故郷での体験談シェア
- お互いの近況報告会

### 📅 第4週: 故郷企画週
- 次回帰省の計画＆情報交換
- 故郷への恩返し企画相談
- 1ヶ月の思い出振り返り

## 🤝 故郷の絆を深める活動
- **方言タイム**: たまには{birthplace}の言葉で話そう
- **故郷写真館**: 懐かしい写真を持ち寄って共有
- **お土産シェア**: 帰省時のお土産をみんなで楽しむ
- **{birthplace}応援団**: 故郷のスポーツチームをみんなで応援

## 🎪 年間特別イベント
- **春**: {birthplace}の桜を思い出すお花見会
- **夏**: 故郷の夏祭り再現パーティー
- **秋**: {birthplace}の紅葉写真展＆芋煮会
- **冬**: 故郷の年末年始文化体験会

## 🔮 ふるさと会のビジョン
どこにいても{birthplace}の心を忘れず、
故郷を愛する仲間と一緒に人生を豊かにしていく。
いつか故郷に恩返しできるような、
素晴らしいコミュニティを築きあげること。

---
💕 {birthplace}の心を大切に、みんなで素敵な思い出を作りましょう！
"""
    
    return content


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(debug=True, host='0.0.0.0', port=port)