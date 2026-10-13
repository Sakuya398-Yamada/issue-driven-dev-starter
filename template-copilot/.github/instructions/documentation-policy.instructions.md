---
applyTo: "**"
description: "copilot-instructions.md・instructions・skills・agents・hooks の書き分け方針"
---

# ドキュメント運用方針

## 読み込みタイミングで 3 層に分ける

| 層 | 置き場所 | いつ読まれるか | 何を書くか |
|---|---|---|---|
| 常駐 | `.github/copilot-instructions.md`、`applyTo: "**"` の `.github/instructions/*.instructions.md` | 常に（全リクエスト） | 毎回の判断に効く規約・判定表・索引だけ。1 行ごとに「この行を消すと Copilot が間違えるか」を自問し、そうでなければ書かない |
| オンデマンド | `.github/skills/<name>/SKILL.md` と補助ファイル（`phases/*.md`・`pitfalls.md` 等）、`applyTo` を絞った instructions、`.github/agents/<name>.agent.md` | `/name` で呼んだとき・`description` が要求に合致したとき／`applyTo` グロブに一致するファイルを扱うとき／サブエージェント起動時 | 複数ステップの手順・チェックリスト・コマンド例（skill 本文と補助ファイルは呼ばれるまで読み込まれない: progressive disclosure）、環境条件付きの回避策、特定領域だけの規約、専門エージェントの指示と出力上限 |
| 人間向け | `docs/`、README、Issue テンプレート本文 | エージェントは読まない | 背景・図解・セットアップ手順・運用の説明 |

`.github/hooks/*.json` はツール実行の前後などイベント発生時に動き、機械的に強制したい規約を置く（文章で頼むのではなく拒否する）。`excludeAgent: "code-review"` / `"cloud-agent"` で instructions の読者を外せる。

- **手順の正本は 1 ファイル**: 同じ手順を 2 箇所に書かない。instructions には判定基準と「正本はどこか」（パスと見出し名）だけを置き、手順本文は skill / phases に置く
- **`copilot-instructions.md` は索引・コア原則のみ**: instructions の一覧とスコープは `copilot-instructions.md`「詳細規約」の表が正本。新しい規約は、コア原則の再定義か全 Phase 横断の絶対ルールでない限り、対応する instructions ファイル（手順なら skill）に書く
- **強調語は本当に効かせたい 1 行だけに使う**: 「必ず」「禁止」を多用すると、どれも目立たなくなる。機械判定できる規約は文章で念押しせず hook / CI で強制する（`git-conventions.instructions.md`「自動検証」）
- **常駐量に予算を置く**: `copilot-instructions.md` と `applyTo: "**"` の instructions の合計（frontmatter を除く）を 1000 行以下に保つ。超えたら棚卸しの合図として `refactor: rules 棚卸し` Issue を切り、`/doctor prompt-audit` 相当の見直しで矛盾・古い記述を洗って統合・削除し、`pitfalls.md` の期限切れも消す。テンプレート元は、プロジェクト固有の instructions の枠を残すため、素のテンプレート分を `tests/check-context-budget.py` で 400 行以下に CI 検査している。閾値を変えるときは理由をコミットメッセージに書く
- **`AGENTS.md` と重複させない**: `AGENTS.md` を置く場合、Copilot は `copilot-instructions.md` と両方を読み込む。同じ内容を二重に書かず、片方からもう片方を参照する

## ハマりどころの書き先

注意書きを足す前に仕分ける。常駐に残すのは 4 だけ。

| 仕分け | 書き先 |
|---|---|
| 1. hook / CI / `.gitattributes` / テストで防げる | それを実装し、文は書かない |
| 2. 手順が不正確・不足だった | 注意書きを足さず、該当 phase のステップ自体を正しい形に書き直す |
| 3. 環境条件付き（特定の OS・ツール・版・端末） | `.github/skills/issue-start/pitfalls.md` に「条件 / 症状 / 回避 / 確認」で 1 項目。該当 phase から見出し名で参照する。常駐 instructions には書かない |
| 4. 横断的な規約 | 対応する instructions に書く（常駐量の予算から払う） |

## 新規 instructions ファイル追加時のチェック

1. スコープが既存 instructions（`copilot-instructions.md`「詳細規約」の表）と重複しないか確認する（重複するなら既存ファイルへの追記を選ぶ）。手順なら instructions ではなく skill にする
2. frontmatter に `applyTo` を書く（プロジェクト全域に効かせるなら `"**"`、特定領域なら `"src/api/**"` のようなグロブ）。`description` も書くと VS Code / CLI がオンデマンドで参照できる
3. `copilot-instructions.md` の「## 詳細規約」テーブルに 1 行追加する
