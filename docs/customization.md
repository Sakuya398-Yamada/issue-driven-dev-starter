# カスタマイズガイド

テンプレートを自分のプロジェクトに合わせて調整するためのガイド。

## ブランチtype / コミットtype を増減する

規約は 3 箇所で同期している。変更時は必ず全部を揃えること：

| 箇所 | 何を変える |
|------|-----------|
| `.claude/rules/git-conventions.md` | 規約の文書（type表・例） |
| `.claude/hooks/validate-branch-name.sh` | 正規表現 `^(feature|fix|refactor|docs)/\#[0-9]+-.+` |
| `.claude/hooks/validate-commit-message.sh` | 正規表現 `^(feat|fix|refactor|test|docs|chore|style):[[:space:]]+.+` |

例: `perf` type を追加するなら、コミット側の正規表現を `^(feat|fix|refactor|test|docs|chore|style|perf):` に変更し、git-conventions.md の表にも追記する。

## Issue番号必須を緩和する

- ブランチ名の Issue 番号を任意にしたい → `validate-branch-name.sh` の正規表現から `\#[0-9]+-` を外す
- コミットの Issue 番号必須を外したい → `validate-commit-message.sh` の後半の `issue_optional` 判定を常に 1 にする（または該当ブロックを削除）

逆に `claude/*` セッションブランチにも Issue 番号を強制したい場合は、両スクリプトの `case ... claude/*)` 除外を削る。

## Phase を増減する

`/issue-start` の Phase は `.claude/skills/issue-start/phases/` のファイル単位で足し引きできる：

1. `phases/` にファイルを追加 / 削除する
2. `SKILL.md` の「Phase一覧」表を更新する（スキップ条件もここで定義）
3. Phase 間の参照（例: Phase 4 の網羅性チェック → Phase 5 のテストガイド）があれば追従する

よくある調整：

- **小規模プロジェクト**: Phase 3（探索）/ Phase 4（設計）を「常時スキップ可」に緩和する
- **レビュー厳格化**: Phase 6 のレビュアー並列数を増やす、信頼度しきい値を下げる（`agents/code-reviewer.md` の `>= 80` を変更）
- **CI連携**: Phase 7 の後に「CI結果確認」Phase を追加する

## サブエージェントの調整

`.claude/agents/*.md` の frontmatter で挙動を変えられる：

- `tools:` — 使わせるツールを制限（explorer に Bash を渡さない等）
- `model:` — `inherit` を `sonnet` 等に固定してコストを抑える
- 「Output Budget」節 — 返却量の上限。Stream タイムアウトが出るなら削る、情報が足りないなら増やす

## MCP サーバー構成

テンプレートは GitHub MCP を前提に書いてあるが、**すべて `gh` CLI にフォールバック可能**：

| 操作 | GitHub MCP | gh CLI |
|------|-----------|--------|
| Issue取得 | `issue_read` | `gh issue view N --comments` |
| Issue作成 | `issue_write` (create) | `gh issue create` |
| コメント | `add_issue_comment` | `gh issue comment N --body-file <tmp>` |
| PR作成 | `create_pull_request` | `gh pr create` |

MCP を使わない運用にする場合は、`settings.json` の `mcp__github__*` permission を削り、SKILL.md / phases 内の MCP 記述を gh CLI に読み替える（Claude は「フォールバック」記述に従って自動的に gh を使うので、実は書き換えなくても動く）。

Web検索（Brave Search）・ドキュメント参照（context7）・UI検証（Playwright）は任意。接続しない場合、各 Phase の該当ステップは自動的にスキップまたは組み込みツールにフォールバックする。

## settings.json の権限

`permissions.allow` はプロジェクトでよく使うコマンドに合わせて追加する（例: `Bash(npm run *)`, `Bash(cargo *)`, `Bash(pytest *)`）。

`permissions.deny` の破壊的コマンド禁止（`rm -rf`, `git push --force`, `git reset --hard` 等）と `.env` 読み書き禁止は、どのプロジェクトでもそのまま残すことを推奨。

## session-start-info.sh の worktree 検出

`session-start-info.sh` には「亡霊 worktree」（`git worktree remove` 後にディレクトリだけ残った状態）の検出が入っている。Claude Code の worktree 機能を使わないプロジェクトでは無害なので残してよいが、不要なら該当セクション（`Ghost worktree detection` 以降）を削っても動く。

## 知見ボードを使わない場合

小規模・短期のプロジェクトで知見ボード運用が過剰なら：

1. `.claude/rules/workflow-feedback.md` を削除
2. `CLAUDE.md` の Memory Imports から該当行を削除
3. `SKILL.md` の「ワークフロー改善余地の知見ボード」節と `phases/08-issue-recording.md` の「5. ワークフロー改善余地」節を削除
