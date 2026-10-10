# カスタマイズガイド

テンプレートを自分のプロジェクトに合わせて調整するためのガイド（Claude Code 版）。Copilot 版で対応先が変わる点は [quickstart-copilot.md](quickstart-copilot.md) の「カスタマイズ」節を参照。

## ブランチtype / コミットtype を増減する

規約は文書と hooks で同期している。変更時は全部を揃えること：

| 箇所 | 何を変える |
|------|-----------|
| `.claude/rules/git-conventions.md` | 規約の文書（type表・例） |
| `.claude/hooks/validate-branch-name.sh` | `convention_re='^(feature|fix|refactor|docs)/#[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'` |
| `.claude/hooks/validate-commit-message.sh` | `type_re='^(feat|fix|refactor|test|docs|chore|style)(\([^)]+\))?!?: [^[:space:]]'` |
| `CLAUDE.md`「自動ガードレール」 | 規約の要約 1 行 |

例: `perf` type を追加するなら、`type_re` を `^(feat|fix|refactor|test|docs|chore|style|perf)(...` に変更し、git-conventions.md の表にも追記する。

Copilot 版も併用しているなら、`template-copilot/` 側の同名スクリプト（`.github/hooks/`、内容は DOC 行以外同一）・`.githooks/`・`validate-conventions.yml` も揃える。このリポジトリの `tests/test-hooks.sh` が全箇所の正規表現が一致しているかを検査するので、テンプレート側を変えたら走らせる。

## Issue番号必須を緩和する

- ブランチ名の Issue 番号を任意にしたい → `validate-branch-name.sh` の `convention_re` から `#[0-9]+-` を外す
- コミットの Issue 番号必須を外したい → `validate-commit-message.sh` の `issue_optional` 判定を常に 1 にする（または該当ブロックを削除）
- 説明部の kebab-case 強制を緩めたい → `convention_re` の `[a-z0-9]+(-[a-z0-9]+)*$` を `.+` に戻す

逆に `claude/*` / `copilot/*` セッションブランチにも Issue 番号を強制したい場合は、両スクリプトの `case ... claude/*|copilot/*)` 除外を削る。

## hooks の仕組みと検証対象

- 両 hook は Claude Code の **PreToolUse**（`Bash` ツール実行前）で動き、stdin の JSON からコマンド文字列を取り出して検証する。JSON パースは `jq` → `node` → `python3` の順で見つかったものを使う。どれも無ければ警告（exit 1、非ブロッキング）を出す
- 検証対象のコマンド形: ブランチ側は `checkout -b/-B/--orphan`、`switch -c/-C/--create`、`branch <name>`、`worktree add -b`。コミット側は `-m` / `-am` / `--message` / heredoc（`-m "$(cat <<'EOF' ...)"`、`-F -`）。`git -C <dir>` や `&&` / 改行で繋いだ複数コマンドも見る。件名はその `git commit` 自身のオプションと同じ行で開いた heredoc からだけ取り出し、heredoc 本文や後続コマンド中の `-m "..."` は拾わない
- 件名を取り出せない形（`-F <file>`、`--amend --no-edit`）は誤検知を避けるため通す
- 同じスクリプトが Copilot の preToolUse hook ペイロード（`toolName` / `toolArgs`）も解釈するので、Copilot 版と共有できる
- 動作確認はこのリポジトリの `tests/test-hooks.sh`（Claude 版・Copilot 版・CI の正規表現同期まで検査する）

PreToolUse hook はサブエージェント内のツール呼び出しにも効く。`git` 以外のコマンドでは JSON パース前に即終了するので、通常のコマンドの遅延はほぼ無い。

## Issue の粒度を調整する

Issue の粒度は `.claude/rules/git-conventions.md` の「粒度」表で定義しており、`/issue-plan`（分割・起票）と `/issue-start` Phase 1（粒度チェック）の **両方が同じ表を参照する**。調整はこの表だけでよい：

- **作業量の目安**（既定: 変更ファイル 10 個以内・差分 300 行以内）: チームの PR レビュー負荷に合わせて増減する。小規模な個人プロジェクトなら大きめ、複数人レビューなら小さめが目安（AI が書いた PR はレビュー負荷が上がりやすく、数百行を超えると指摘が急増する）
- **「分ける／分けない」表**: プロジェクト特有の判断（例: 「DB マイグレーションは必ず単独 Issue」「UI と API は縦に切る」）を行として足す
- **親Issue を作る閾値**（既定: 3 件以上）: 「依存関係と親Issue」節の数値を変える

Phase 1 の粒度チェックで分割提案が多すぎる／少なすぎると感じたら、閾値を変えるより先に表の文言が曖昧でないかを疑い、知見ボードに残す。

## `/issue-plan` を使わない場合

Issue を常に手書きする運用なら `.claude/skills/issue-plan/` を削除し、`CLAUDE.md` の「開発フロー」と `git-conventions.md`「依存関係と親Issue」の `/issue-plan` への言及を消す。粒度の表自体は `/issue-start` Phase 1 のチェックで使うので残しておく。

## Phase を増減する

`/issue-start` の Phase は `.claude/skills/issue-start/phases/` のファイル単位で足し引きできる：

1. `phases/` にファイルを追加 / 削除する
2. `SKILL.md` の「Phase一覧」表を更新する（スキップ条件もここで定義）
3. Phase 間の参照（例: Phase 4 の網羅性チェック → Phase 5 のテストガイド、Phase 1 手順 0.5 ↔ `workflow-feedback.md`、Phase 8 手順 6 ↔ `workflow-feedback.md`）があれば追従する

よくある調整：

- **小規模プロジェクト**: Phase 3（探索）/ Phase 4（設計）のスキップ条件を広げる（既定でも「1 文で説明できる変更」は Phase 4 をスキップする）
- **レビュー厳格化**: Phase 6 のレビュアー観点を増やす、信頼度しきい値を下げる（`agents/code-reviewer.md` の `>= 80` を変更）、組み込みの `/code-review` や `/security-review` を Phase 6 に組み込む
- **CI連携**: Phase 7 の後に「CI結果確認」Phase を追加する（`pull_request_read` の `get_check_runs` で状態を取れる）
- **plan mode 前提**: Phase 4 の承認を `ExitPlanMode` に統一するなら、`.claude/settings.json` に `"permissions": {"defaultMode": "plan"}` を足してセッションを plan mode で始める

## サブエージェントの調整

`.claude/agents/*.md` の frontmatter で挙動を変えられる：

- `tools:` — 使わせるツールを制限（explorer に Bash を渡さない等）
- `model:` — `inherit`（既定）を `haiku` / `sonnet` 等に固定する。探索を安く回したいなら `code-explorer` を `haiku` にする手がある（Claude Code 組み込みの `Explore` エージェントは既定で主会話と同じモデルを使う）
- `effort:` — `low` 〜 `max` で思考量を変える
- `maxTurns:` — 暴走防止のターン上限
- 「Output Budget」節 — 返却量の上限。情報が足りないなら増やし、主会話のコンテキストが膨らむなら削る
- 起動数の目安（1〜3 個）は `.claude/rules/context-efficiency.md`「起動数の目安」と各 Phase の表で変えられる

組み込みの `Explore` / `Plan` エージェントで代用することもできる。違いは、テンプレートのエージェントは `CLAUDE.md` と `.claude/rules/` を読んだ上で動き、Project Context と返却量の既定値を持つこと（`Explore` / `Plan` は CLAUDE.md を読まない）。

## MCP サーバー構成

テンプレートは `.mcp.json` で GitHub のリモート MCP サーバー（`https://api.githubcopilot.com/mcp/`）を登録している。初回起動時にプロジェクト MCP の利用を承認し、`/mcp` で OAuth 認証する。毎回の承認を省きたいなら `.claude/settings.json` に `"enableAllProjectMcpServers": true` を足す。

**すべて `gh` CLI にフォールバック可能**：

| 操作 | GitHub MCP | gh CLI |
|------|-----------|--------|
| Issue取得 | `issue_read`（`get` / `get_comments` / `get_sub_issues`） | `gh issue view N --comments` |
| Issue作成 | `issue_write`（`create`、`parent_issue_number` で sub-issue） | `gh issue create`（`--parent` は gh 2.94 以降） |
| Issue検索 | `search_issues`（`owner` / `repo` で絞る） | `gh issue list --search` |
| コメント | `add_issue_comment` / `update_issue_comment` | `gh issue comment N --body-file <tmp>` / `gh api` |
| PR作成 | `create_pull_request` | `gh pr create` |

MCP を使わない運用にする場合は `.mcp.json` を削除し、`settings.json` の `mcp__github__*` permission を削る。SKILL.md / phases 内の MCP 記述は「フォールバック」に従って `gh` に読み替えられるので、書き換えなくても動く。

ドキュメント参照（context7）・UI検証（Playwright）・Web検索 MCP は任意。接続しない場合、各 Phase の該当ステップは組み込みの `WebSearch` / `WebFetch` にフォールバックするか、スキップして「未検証」と報告する。

## settings.json の権限

`permissions.allow` はプロジェクトでよく使うコマンドに合わせて追加する（例: `Bash(npm run *)`, `Bash(cargo *)`, `Bash(pytest *)`）。書式は `Bash(コマンド *)`（`Bash(npm run:*)` と同義）。

`permissions.deny` の破壊的コマンド禁止（`rm -rf`, `git push --force`（引数の途中に来る形も含む）, `git reset --hard` 等）と `.env` の読み書き禁止は、どのプロジェクトでもそのまま残すことを推奨。deny は allow より先に評価されるので、allow で穴を開けることはできない。パスのルールは `Read(...)` / `Edit(...)` だけが評価される（`Write(...)` は無視されるので書かない。`Read` の deny は Edit / Write も塞ぐ）。

permission の deny はコマンド文字列の一致で判定するため、`git -C . push --force` のような書き方は素通りする。確実に止めたいなら hook で検査する。

## session-start-info.sh

「亡霊 worktree」（`git worktree remove` 後にディレクトリだけ残った状態）の検出と、テンプレート更新チェック（`.claude/template-version` と最新 Release タグの比較、24 時間キャッシュ）が入っている。`claude --worktree` を使わないプロジェクトでは無害なので残してよいが、不要なら該当セクション（`Ghost worktree detection`）を削っても動く。末尾の「行動原則リマインダー」はプロジェクトの方針に合わせて書き換えてよい（短く保つ）。

SessionStart hook は `matcher` を指定していないので、起動・再開・`/clear`・コンパクション後のすべてで走り、バナーを再注入する。

## 知見ボードを使わない場合

小規模・短期のプロジェクトで知見ボード運用が過剰なら：

1. `.claude/rules/workflow-feedback.md` を削除
2. `CLAUDE.md` の「詳細規約」テーブルから該当行を削除
3. `SKILL.md` の「ワークフロー改善の知見ボード」節と `phases/08-issue-recording.md` の「5. ワークフロー改善余地」「6. テンプレート元への還元」節を削除

## テンプレート元への還元 / 更新チェックを止める・向け先を変える

知見ボードは使うが、社外（このスターターキット）への還元はしない運用にする場合：

1. `.claude/rules/workflow-feedback.md` の「テンプレート元への還元」節を削除し、記入フォーマットの `**還元先**` 行を消す
2. `phases/08-issue-recording.md` の「6. テンプレート元への還元」節を削除
3. `SKILL.md` の知見ボード節にある「テンプレート元への還元」の箇条書きを削除

更新チェックも止める場合は、さらに `.claude/template-version` を削除する（SessionStart hook はファイルが無ければ何も出さない）。`phases/01-issue-analysis.md` の「0.5 テンプレート更新チェック」節と `workflow-feedback.md` の「テンプレート元の情報」「テンプレート更新の取り込み」節も削ってよい。

更新チェックのネットワークアクセスだけ避けたい（社内プロキシ等）場合は `session-start-info.sh` の `Template update check` セクションを削るか、`.claude/template-version` を削除する。

フォークした独自テンプレートに向けたい場合は、削除ではなく `.claude/template-version` の `repo` を書き換える（[upstream-feedback.md](upstream-feedback.md)「フォークして独自テンプレートにする場合」）。

## 変更後の点検

CLAUDE.md や rules を大きく変えたら、`/context` で読み込まれているファイルと消費量を確認し、`/doctor prompt-audit` で冗長・矛盾した指示が無いか点検する。hooks を変えたら `tests/test-hooks.sh` を通す。
