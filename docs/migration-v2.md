# v1.x → v2.0.0 移行手順（手動対応）

v2.0.0 はテンプレートを現行の Claude Code 仕様に合わせて全面的に整理した版で、**利用プロジェクト側に手作業が要る変更** を含む。更新用 Issue（`refactor: テンプレートを v2.0.0 に更新`）を `/issue-start` したときは、[upstream-feedback.md](upstream-feedback.md)「取り込み（更新用 Issue を `/issue-start` したとき）」と、利用プロジェクト側の `/template-update` skill（`.claude/skills/template-update/SKILL.md`。v2.0.x では `workflow-feedback.md`「取り込み手順」）の手順に加えて以下を行う。差分の全体は [v1.0.0...v2.0.0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v1.0.0...v2.0.0)。

Copilot 版の手順は、切り出した先のリポジトリ（[issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot)）の同じファイルにある。

## 規約・hooks

| 変更 | 手作業 |
|------|--------|
| ブランチ名の説明部が kebab-case（小文字英数字と単独ハイフン）で機械検証されるようになった | 進行中のブランチ名が大文字・アンダースコアを含むなら、PR を出す前に `git branch -m` で改名する。緩めたい場合は hooks の `convention_re` を変える（[customization.md](customization.md)「Issue番号必須を緩和する」） |
| コミット件名は `<type>[(scope)][!]: <subject>` で、コロン後は空白 1 つ | 旧 hook が通していた `feat:  x`（空白 2 つ）や `feat:x` は拒否される |
| hooks の JSON パースが `node` 固定から `jq` → `node` → `python3` の順に変わった | いずれか 1 つがあれば動く。何も無い環境では警告が出る |
| Issue の親子付けが GitHub の sub-issue 前提になった | `親Issue: #N` の本文記法は代替手段として残る。`gh` CLI の `--parent` は 2.94 以降 |
| `.gitattributes` が同梱された | 既に `.gitattributes` があれば `*.sh text eol=lf` をマージする |

## ファイル・設定

| 変更 | 手作業 |
|------|--------|
| `.claude/rules/*.md` は自動読み込みのため、CLAUDE.md の `@.claude/rules/...` 行を削除した | 自分の CLAUDE.md からも `@import` 行を消す（残すと二重読み込み）。`/context` で rules が 1 回だけ読まれていることを確認 |
| `settings.json` の `Write(**/.env)` を削除、force-push の deny パターンを追加、hook コマンドの引用符と `timeout` を追加 | 自分の `settings.json` に `allow` を足していた場合は、テンプレートの `settings.json` を差分で取り込む |
| `.mcp.json`（GitHub MCP）を同梱 | 既に別の方法で GitHub MCP を登録しているなら不要。使うなら初回に `/mcp` で OAuth 認証 |
| `.gitignore` に `.claude/worktrees/` と `.claude/settings.local.json` を追記する手順を追加 | 無ければ追記する |
| CLAUDE.md の開発方針を書き換え（「3 回ツール呼び出しで質問」「500 行超は全読み禁止」等を廃止） | CLAUDE.md のプロジェクト固有部分（名前・概要）を残して「開発方針」以降を差し替える |
| agents / skills / phases を全面改訂 | テンプレート由来なのでそのまま上書きしてよい。agents 末尾の Project Context と SKILL.md の知見ボード番号・MCP 表だけ自分の値を戻す |

## 取り込み後の確認

- `/context` で rules が読み込まれている、SessionStart バナーが `up to date`、`git checkout -b test-branch` が拒否される
- `.claude/template-version` の `version` を `v2.0.0` にする
