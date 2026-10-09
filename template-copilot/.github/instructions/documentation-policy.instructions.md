---
applyTo: "**"
description: "copilot-instructions.md・instructions・skills・agents・hooks の書き分け方針"
---

# ドキュメント運用方針

## Copilot のカスタマイズ機構と使い分け

| 置き場所 | いつ読まれるか | 何を書くか |
|---------|--------------|-----------|
| `.github/copilot-instructions.md` | 常に（全リクエスト） | コア原則と索引だけ。1 行ごとに「この行を消すと Copilot が間違えるか」を自問し、そうでなければ書かない |
| `.github/instructions/*.instructions.md` | frontmatter の `applyTo` グロブに一致するファイルを扱うとき | 領域ごとの具体的な規約。`applyTo: "**"` で常時適用、`"src/api/**"` のように絞ると該当時だけ読まれる。`excludeAgent: "code-review"` / `"cloud-agent"` で特定の読者を外せる |
| `.github/skills/<name>/SKILL.md` | `/name` で呼んだとき、または `description` が要求に合致したとき | 手順書（ワークフロー）。本文は呼ばれるまで読み込まれず、参照している補助ファイル（`phases/*.md` 等）は必要になるまで読み込まれない（progressive disclosure） |
| `.github/agents/<name>.agent.md` | サブエージェントとして起動したとき | 役割を固定した専門エージェントの指示と出力上限 |
| `.github/hooks/*.json` | ツール実行の前後など、イベント発生時 | 機械的に強制したい規約（文章で頼むのではなく拒否する） |

## 基本方針

- **`copilot-instructions.md` は索引・コア原則のみに保つ**: 中核となる開発方針（Issue駆動開発、1 Issue = 1 PR、確認ポイント、検証してから完了など）と、詳細規約ファイルへの索引だけを置く
- **詳細規約は `.github/instructions/*.instructions.md` に分離する**: 個別領域ごとの具体的な規約・運用手順・リファレンスは instructions 側に置く
- **「いつも読む必要はない手順」は skills に逃がす**: `/issue-start` のようなワークフローは常時コンテキストに入れず、呼ばれたときだけ読まれる skill にする
- **強調語は本当に効かせたい 1 行だけに使う**: 「必ず」「禁止」を多用すると、どれも目立たなくなる。機械判定できる規約は文章で念押しせず hook / CI で強制する（`git-conventions.instructions.md`「自動検証」）
- **`AGENTS.md` と重複させない**: `AGENTS.md` を置く場合、Copilot は `copilot-instructions.md` と両方を読み込む。同じ内容を二重に書かず、片方からもう片方を参照する

## 既存 instructions ファイルとスコープ

| ファイル | スコープ |
|---------|---------|
| `git-conventions.instructions.md` | ブランチ・コミット・PR・Issue 規約 |
| `coding-standards.instructions.md` | 言語規約・命名・ディレクトリ構成・コメント方針 |
| `tech-stack.instructions.md` | 技術スタック・開発環境・コマンド |
| `context-efficiency.instructions.md` | コンテキスト効率・ファイル読解・サブエージェント委譲 |
| `workflow-feedback.instructions.md` | 知見ボード運用、テンプレート元への還元・更新取り込み |
| `documentation-policy.instructions.md` | ドキュメント運用方針（このファイル） |

## 新規 instructions ファイル追加時のチェック

1. スコープが既存 instructions と重複しないか確認する（重複するなら既存ファイルへの追記を選ぶ）
2. frontmatter に `applyTo` を書く（プロジェクト全域に効かせるなら `"**"`、特定領域なら `"src/api/**"` のようなグロブ）。`description` も書くと VS Code / CLI がオンデマンドで参照できる
3. `copilot-instructions.md` の「## 詳細規約」テーブルに 1 行追加する

## 「copilot-instructions.md にも追記」と書きたくなったら

実装中・Issue 本文で「copilot-instructions.md にも追記する」のような表現が出てきたら、まず「索引・コア原則として置くべき内容か」を自問する。次のいずれかに該当しなければ、対応する instructions ファイル（または skill）側に書く：

- プロジェクトのコア原則そのもの（既存「## 開発方針」と同等のレイヤー）
- 全 Phase / 全領域に横断的に効く絶対ルール
- 詳細規約ファイルが分かれていない領域への新規索引追加
