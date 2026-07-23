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
| CI | GitHub Actions | 規約検証（validate-conventions.yml）を含む |
| Issue/PR操作 | GitHub MCP または `gh` CLI | Issue / PR の取得・作成・コメント・ラベル付与等を Copilot セッションから操作 |

## 開発環境

- 必要ツール: git、`gh` CLI（または VS Code に設定した GitHub MCP サーバー）
- 初回セットアップ: `git config core.hooksPath .githooks` でローカルガードレールを有効化する

## よく使うコマンド

| コマンド | 説明 |
|---------|------|
| `npm run dev` | 開発サーバー起動 |
| `npm test` | テスト一括実行 |
