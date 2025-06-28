# Me-Too!（ミートゥー） アーキテクチャ図

```mermaid
graph TD
    subgraph "フロントエンド"
        A[Flutter App<br/>Dart]
        A --> |ユーザー認証| B[Firebase Auth]
        A --> |プロフィール検索| C[Flask API Server]
        A --> |リアルタイム更新| D[Firestore DB]
    end

    subgraph "バックエンド"
        C[Flask API Server<br/>Python] --> |検索クエリ| D[Firestore DB]
        C --> |CORS対応| A
        C --> |ヘルスチェック| E[Monitoring]
    end

    subgraph "データベース"
        D[Firestore DB] --> |ユーザープロフィール| F[profiles collection]
        F --> |検索インデックス| G[hobby_keywords]
        F --> |フィルタリング| H[birthplace]
    end

    subgraph "認証・セキュリティ"
        B[Firebase Auth] --> |認証情報| I[Google Cloud IAM]
        I --> |サービスアカウント| C
    end

    subgraph "デプロイメント"
        J[Google Cloud Platform]
        J --> |ホスティング| C
        J --> |ストレージ| D
        J --> |認証| B
    end

    subgraph "開発環境"
        K[Local Development]
        K --> |Flutter Web| A
        K --> |Flask Dev Server| C
        K --> |環境変数| L[.env]
    end

    style A fill:#4CAF50,stroke:#333,stroke-width:2px,color:#fff
    style C fill:#2196F3,stroke:#333,stroke-width:2px,color:#fff
    style D fill:#FF9800,stroke:#333,stroke-width:2px,color:#fff
    style B fill:#F44336,stroke:#333,stroke-width:2px,color:#fff
    style J fill:#9C27B0,stroke:#333,stroke-width:2px,color:#fff
```

## データフロー

```mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant A as Firebase Auth
    participant B as Flask Backend
    participant D as Firestore DB

    U->>F: アプリ起動
    F->>A: 認証確認
    A-->>F: 認証状態返却
    
    U->>F: 検索実行
    F->>B: POST /search
    B->>D: クエリ実行
    D-->>B: 検索結果
    B-->>F: JSON レスポンス
    F-->>U: 結果表示
```

## 技術仕様

### フロントエンド
- **技術**: Flutter (Dart)
- **プラットフォーム**: Web, iOS, Android
- **認証**: Firebase Auth
- **状態管理**: Provider/Riverpod

### バックエンド
- **技術**: Flask (Python)
- **API**: RESTful API
- **CORS**: 有効化済み
- **ポート**: 5000

### データベース
- **技術**: Firestore
- **コレクション**: profiles
- **インデックス**: hobby_keywords (配列), birthplace (文字列)

### 検索機能
- **趣味検索**: array_contains クエリ
- **出身地検索**: 完全一致クエリ
- **複合検索**: AND条件