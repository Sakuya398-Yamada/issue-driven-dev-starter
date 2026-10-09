---
applyTo: "**"
description: "技術スタック・開発環境・よく使うコマンド"
---

# 技術スタック

## レイヤー構成

| レイヤー | 技術 | 備考 |
|---------|------|------|
| 言語 | <言語> | |
| フロントエンド | <フレームワーク> | |
| バックエンド | <フレームワーク> | |
| DB | <DB> | |
| テスト | <テストランナー> | `npm test` 等の実行コマンドも書く |
| CI | GitHub Actions | 規約検証（`validate-conventions.yml`）を含む |
| Issue/PR操作 | GitHub MCP または `gh` CLI | Issue / PR の取得・作成・コメント・ラベル付与・sub-issue 紐づけを Copilot セッションから操作 |

## 開発環境

- 必要ツール: git、bash（Windows は Git Bash）、`jq`（無ければ `node` か `python3`。preToolUse hook が JSON パースに使う）、`gh` CLI
- GitHub 操作: GitHub MCP サーバー（Copilot CLI / cloud agent は組み込み、VS Code は `.vscode/mcp.json` に `https://api.githubcopilot.com/mcp/` を登録）。未接続時は `gh` CLI にフォールバック
- 初回セットアップ: `git config core.hooksPath .githooks` でローカル git hooks を有効化する（preToolUse hook は `.github/hooks/` にあるので設定不要）
- Copilot cloud agent を使う場合: 依存関係のインストールは `.github/workflows/copilot-setup-steps.yml` に書く（デフォルトブランチに置く）

## よく使うコマンド

| コマンド | 説明 |
|---------|------|
| `npm run dev` | 開発サーバー起動 |
| `npm test` | テスト一括実行 |
