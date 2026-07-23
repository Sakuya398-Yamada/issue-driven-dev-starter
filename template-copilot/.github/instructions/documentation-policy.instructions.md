---
applyTo: "**"
description: "copilot-instructions.md と instructions の書き分け方針"
---

# ドキュメント運用方針

## 基本方針

- **`copilot-instructions.md` は索引・コア原則のみに保つ**: プロジェクトの中核となる開発方針（Issue駆動開発、1 Issue = 1 PR、推測しない、思考よりも対話、中間報告など）と、詳細規約ファイルへの索引だけを置く場所
- **詳細規約は `.github/instructions/*.instructions.md` に分離する**: 個別領域ごとの具体的な規約・運用手順・リファレンスは `.github/instructions/` 配下に配置する。frontmatter の `applyTo` グロブに基づいて Copilot に自動適用される
- **新規規約を追加するときは原則 instructions 側を作成・更新する**: コア原則そのものの再定義でなければ、copilot-instructions.md 本文を直接膨らませず、対応する instructions ファイル（既存 or 新規）を編集する。copilot-instructions.md 側の更新は索引テーブルへの 1 行追加で済むのが理想

## 既存 instructions ファイルとスコープ

| ファイル | スコープ |
|---------|---------|
| `git-conventions.instructions.md` | ブランチ・コミット・PR・Issue 規約 |
| `coding-standards.instructions.md` | 言語規約・命名・ディレクトリ構成・コメント方針 |
| `tech-stack.instructions.md` | 技術スタック・開発環境・コマンド |
| `workflow-feedback.instructions.md` | ワークフロー改善知見ボード運用 |
| `documentation-policy.instructions.md` | ドキュメント運用方針（このファイル） |

## 新規 instructions ファイル追加時のチェック

1. スコープが既存 instructions と重複しないか確認（重複するなら既存ファイルへの追記を選ぶ）
2. frontmatter に `applyTo` を記載する（プロジェクト全域に効かせるなら `"**"`、特定領域なら `"src/api/**"` のようなグロブ）
3. copilot-instructions.md の「## 詳細規約」テーブルに 1 行追加する

## 「copilot-instructions.md にも追記」と書きたくなったら

実装中・Issue 本文で「copilot-instructions.md にも追記する」のような表現が出てきたら、まず「索引・コア原則として置くべき内容か」を自問する。次のいずれかに該当しなければ、対応する instructions ファイル側に書く方を選ぶ：

- プロジェクトのコア原則そのもの（既存「## 開発方針」と同等のレイヤー）
- 全 Phase / 全領域に横断的に効く絶対ルール
- 詳細規約ファイルが分かれていない領域への新規索引追加
