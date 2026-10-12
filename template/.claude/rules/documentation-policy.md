# ドキュメント運用方針

`.claude/rules/` 配下のファイルは Claude Code が起動時に自動で読み込む（CLAUDE.md からの `@import` は不要）。

## 読み込みタイミングで 3 層に分ける

| 層 | 置き場所 | 読まれるタイミング | 何を書くか |
|---|---|---|---|
| 常駐 | `CLAUDE.md`、`paths:` なしの `.claude/rules/*.md` | 毎セッションの起動時 | 毎セッションの判断に効く規約・判定表・索引だけ。1 行ごとに「この行を消すと Claude が間違えるか」を自問し、そうでなければ書かない |
| オンデマンド | `.claude/skills/*/SKILL.md` と補助ファイル（`phases/*.md` 等）、frontmatter に `paths:` を書いた rules | skill を呼んだとき／`paths` に一致するファイルを Read・Edit・Write したとき | 複数ステップの手順・チェックリスト・コマンド例、特定領域（言語・層）だけの規約 |
| 人間向け | `docs/`、README、Issue テンプレート本文 | Claude は読まない | 背景・図解・セットアップ手順・運用の説明 |

- **手順の正本は 1 ファイル**: 同じ手順を 2 箇所に書かない。rules には判定基準と「正本はどこか」（パスと見出し名）だけを置き、手順本文は skill / phases に置く
- **CLAUDE.md は索引・コア原則のみ**: 新しい規約は、コア原則の再定義か全 Phase 横断の絶対ルールでない限り、対応する rules ファイルに書く。CLAUDE.md 側の更新は索引テーブルへの 1 行追加で済むのが理想
- **強調語は本当に効かせたい 1 行だけに使う**: 「必ず」「禁止」を多用すると、どれも目立たなくなる。機械判定できる規約は文章で念押しせず hook で強制する（`git-conventions.md`「自動検証」）

## 既存 rules ファイルとスコープ

| ファイル | スコープ |
|---------|---------|
| `git-conventions.md` | ブランチ・コミット・PR・Issue 規約 |
| `coding-standards.md` | 言語規約・命名・ディレクトリ構成・コメント方針 |
| `tech-stack.md` | 技術スタック・開発環境・コマンド |
| `context-efficiency.md` | コンテキスト効率・ファイル読解・サブエージェント委譲 |
| `workflow-feedback.md` | 知見ボード運用、テンプレート元への還元・更新取り込みの判定（手順は phases と `/template-update`） |
| `documentation-policy.md` | ドキュメント運用方針（このファイル） |

## 新規 rules ファイル追加時のチェック

1. スコープが既存 rules と重複しないか確認する（重複するなら既存ファイルへの追記を選ぶ）。手順なら rules ではなく skill にする
2. `.claude/rules/<name>.md` に置く。特定のファイル群にだけ効かせたいなら frontmatter に `paths:`（例: `paths: ["src/api/**/*.ts"]`）を書く
3. CLAUDE.md の「## 詳細規約」テーブルに 1 行追加する（`@import` は書かない。二重に読み込まれる）
4. 大きく変えたら `/context` で読み込まれているファイルと消費量を確認し、`/doctor prompt-audit` で冗長・矛盾した指示が無いか点検する
