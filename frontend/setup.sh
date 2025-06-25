#!/bin/bash

# ProfileAI フロントエンド セットアップスクリプト
# 新規参画者向けの自動セットアップ

set -e  # エラー時に停止

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# プロジェクト情報
PROJECT_NAME="ProfileAI"
PROJECT_VERSION="1.0.0"

print_header() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║           ProfileAI セットアップ             ║"
    echo "║        AIハッカソン2025 フロントエンド        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_step() {
    echo -e "${CYAN}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Flutter環境の確認
check_flutter() {
    print_step "Flutter環境を確認中..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutterがインストールされていません"
        echo -e "${YELLOW}以下のURLからFlutterをインストールしてください:${NC}"
        echo "https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    # Flutterバージョンの確認
    FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
    print_success "Flutter ${FLUTTER_VERSION} が見つかりました"
    
}

# 依存関係のインストール
install_dependencies() {
    print_step "依存関係をインストール中..."
    
    # pubspec.yamlの存在確認
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yamlが見つかりません"
        print_info "正しいディレクトリで実行していることを確認してください"
        exit 1
    fi
    
    # パッケージの取得
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "依存関係のインストールが完了しました"
    else
        print_error "依存関係のインストールに失敗しました"
        exit 1
    fi
}

