# カスタマイズガイド

テンプレートを自分のプロジェクトに合わせて調整するためのガイド。Copilot 版は、切り出した先のリポジトリ（[issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot)）のクイックスタートの「カスタマイズ」節を参照。

## ブランチtype / コミットtype を増減する

規約は文書と hooks で同期している。変更時は全部を揃えること：

| 箇所 | 何を変える |
|------|-----------|
| `.claude/rules/git-conventions.md` | 規約の文書（type表・例） |
| `.claude/hooks/validate-branch-name.sh` | `convention_re='^(feature|fix|refactor|docs)/#[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'` |
| `.claude/hooks/validate-commit-message.sh` | `type_re='^(feat|fix|refactor|test|docs|chore|style)(\([^)]+\))?!?: [^[:space:]]'` |

例: `perf` type を追加するなら、`type_re` を `^(feat|fix|refactor|test|docs|chore|style|perf)(...` に変更し、git-conventions.md の表にも追記する。

テンプレート元で変えたときは、このリポジトリの `tests/test-hooks.sh` を走らせる（hooks の判定を検査する）。

## Issue番号必須を緩和する

- ブランチ名の Issue 番号を任意にしたい → `validate-branch-name.sh` の `convention_re` から `#[0-9]+-` を外す
- コミットの Issue 番号必須を外したい → `validate-commit-message.sh` の `issue_optional` 判定を常に 1 にする（または該当ブロックを削除）
- 説明部の kebab-case 強制を緩めたい → `convention_re` の `[a-z0-9]+(-[a-z0-9]+)*$` を `.+` に戻す

逆に `claude/*` / `copilot/*` セッションブランチにも Issue 番号を強制したい場合は、両スクリプトの `case ... claude/*|copilot/*)` 除外を削る。

## hooks の仕組みと検証対象

- 両 hook は Claude Code の **PreToolUse**（`Bash` ツール実行前）で動き、stdin の JSON からコマンド文字列を取り出して検証する。JSON パースは `jq` → `node` → `python3` の順で見つかったものを使う。どれも無ければ検証できないので、そのコマンドを止める（exit 2）
- hook 自体が時間切れ・起動できない・exit 0 / 2 以外で終わったときも、`settings.json` の `"onFailure": "block"` でツールの呼び出しを止める（既定の `continue` だと、検証されないまま通る）
- 検証対象のコマンド形: ブランチ側は `checkout -b/-B/--orphan`、`switch -c/-C/--create`、`branch <name>`、`worktree add -b`。コミット側は `-m` / `-am` / `--message` / heredoc（`-m "$(cat <<'EOF' ...)"`、`-F -`）。`git -C <dir>` や `&&` / 改行で繋いだ複数コマンドも見る。件名はその `git commit` 自身のオプションと同じ行で開いた heredoc からだけ取り出し、heredoc 本文や後続コマンド中の `-m "..."` は拾わない
- 件名を取り出せない形（`-F <file>`、`--amend --no-edit`）は誤検知を避けるため通す
- 同じスクリプトが Copilot の preToolUse hook ペイロード（`toolName` / `toolArgs`）も解釈する（Copilot 版と共有していたため。Copilot 版は [issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot) に切り出した）
- 動作確認はこのリポジトリの `tests/test-hooks.sh`
- Claude Code 版にはもう 1 つ `validate-pkill-pattern.sh` がある。Bash ツールはコマンドの全文をコマンドラインに持つシェルで実行するので、`pkill -f` / `pgrep -f` のパターンがその全文に一致すると、シェル自身を落とす・一覧に出す。`-f` があり `-A` / `-x` が無く、パターン（拡張正規表現）がコマンドの全文に一致するときに止める。変数やコマンド置換で組んだパターンは確かめられないので止める。要らなければ `settings.json` の登録ごと消す
- `validate-push-target.sh` は、`main`（既定ブランチ）への直接の push を止める。止める形と止まらない形は「settings.json の権限」

PreToolUse hook はサブエージェント内のツール呼び出しにも効く。`git` / `pkill` / `pgrep` を含まないコマンドでは JSON パース前に即終了するので、通常のコマンドの遅延はほぼ無い。

## Issue の粒度を調整する

Issue の粒度の既定は `.claude/rules/git-conventions.md` の「粒度」表（常駐）、分ける／分けないの判定表と親Issue の扱いは `.claude/skills/issue-plan/SKILL.md`「粒度の判定」（`/issue-plan` を呼んだときだけ読まれる）で定義している。既定では、変更の行数やファイル数ではなく、目的が 1 つ・`/issue-start` Phase 4 の設計承認 1 回で判断しきれる・まとめて revert してよい・単独でマージして壊れない、の 4 つで範囲を決める。`/issue-start` Phase 1 の粒度チェックも同じ基準（目的が複数／設計承認 1 回で判断しきれない／一部だけ先にマージしたい・戻したくなる塊がある）で止まる。

v2.7.x までは「変更ファイル 10 個以内・差分 300 行以内・完了条件 7 個超で分割」という数の目安があった。コンテキスト窓が小さかった頃に「1 セッションで Phase 1〜8 を完走できる量」から逆算した値で、1M トークンの窓と自動の compaction がある今は前提が外れている。数で切ると、各セッションが切れ端だけを見て既存の構造に足すだけの変更に寄るので外した（[#319](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/319)）。調整できるのは次のとおり：

- **差分の目安を足す**（人がコードを読んでレビューするプロジェクト向け）: `git-conventions.md`「粒度」表に作業量の行（例: 「差分 400 行以内。テスト・生成物・lock ファイルは数えない」）を足し、`issue-plan`「粒度の判定」の分ける側と、`phases/01-issue-analysis.md` の粒度チェックの止まる条件にも同じ行を足す（足したら、同じ段落の「完了条件の個数・ラベルの数・変更の大きさだけでは止めない」から「変更の大きさ」を外す）。目安には、1 回のレビューで読めるのは 200〜400 行・60〜90 分が上限という調査が使える（[SmartBear の Cisco での調査](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/)）。ただし上のとおり局所的な変更に寄りやすくなるので、レビューの負荷が実際に問題になってから足す
- **「分ける／分けない」表**: `.claude/skills/issue-plan/SKILL.md`「粒度の判定」。プロジェクト特有の判断（例: 「DB マイグレーションは必ず単独 Issue」「UI と API は縦に切る」）を行として足す
- **親Issue を作る閾値**（既定: 3 件以上）: 同じ「粒度の判定」節の数値を変える

Phase 1 の粒度チェックで分割提案が多すぎる／少なすぎると感じたら、基準や閾値を足す前に表の文言が曖昧でないかを疑い、知見ボードに残す。

## ハマりどころを足す

注意書きを rules に足す前に `.claude/rules/documentation-policy.md`「ハマりどころの書き先」で仕分ける（hook で防ぐ・手順を直す・pitfalls・rules）。特定の OS・ツール・版に条件付けられたものは `.claude/skills/issue-start/pitfalls.md`（条件が Claude Code のクラウドセッションのものは `.claude/skills/issue-start/pitfalls-cloud.md`）に「条件 / 症状 / 回避 / 確認（版 / 年月 / 出自 Issue）」で 1 項目足し、該当 phase から見出し名で参照する。rules には書かない（常駐量が増える）。確認から 6 か月経った項目は棚卸しで見直し、起きなくなっていれば消す。

## `/issue-plan` を使わない場合

Issue を常に手書きする運用なら `.claude/skills/issue-plan/` を削除し、`CLAUDE.md` の「開発フロー」と `git-conventions.md`「粒度」の `/issue-plan` への言及を消す。「粒度」表自体は `/issue-start` Phase 1 のチェックで使うので残しておく。

## Phase を増減する

`/issue-start` の Phase は `.claude/skills/issue-start/phases/` のファイル単位で足し引きできる：

1. `phases/` にファイルを追加 / 削除する
2. `SKILL.md` の「Phase一覧」表を更新する（スキップ条件もここで定義）
3. Phase 間の参照（例: Phase 4 の網羅性チェック → Phase 5 のテストガイド、Phase 1 手順 0.5 ↔ `.claude/skills/template-update/SKILL.md`、Phase 8 手順 5・6 ↔ `workflow-feedback.md` の判定表）があれば追従する

よくある調整：

- **小規模プロジェクト**: Phase 3（探索）/ Phase 4（設計）のスキップ条件を広げる（既定でも「1 文で説明できる変更」は Phase 4 をスキップする。手順書・規約から人の確認を外す・弱める変更と、ルーティンの手順書・`/issue-priority` を変える変更は除く）
- **レビュー厳格化**: Phase 6 のレビュアー観点を増やす、主セッションが見送る基準（`phases/06-review.md` 手順 4）を狭める、組み込みの `/code-review` や `/security-review` を Phase 6 に組み込む（v2.7.x までは `agents/code-reviewer.md` が信頼度 80 未満の指摘を返さなかったが、今は全部返して主セッションが絞る）
- **CI連携**: Phase 7 の後に「CI結果確認」Phase を追加する（`pull_request_read` の `get_check_runs` で状態を取れる）
- **plan mode 前提**: Phase 4 の承認を `ExitPlanMode` に統一するなら、`.claude/settings.json` に `"permissions": {"defaultMode": "plan"}` を足してセッションを plan mode で始める

## サブエージェントの調整

`.claude/agents/*.md` の frontmatter で挙動を変えられる：

- `tools:` — 使わせるツールを制限（explorer に Bash を渡さない等）
- `model:` — 既定は、`code-explorer` が `sonnet`、`code-architect` と `code-reviewer` が `inherit`（主会話と同じ）。探索をさらに安く回したいなら `code-explorer` を `haiku` に、探索も主会話と同じモデルにしたいなら `inherit` に戻す。呼び出しごとの `model` 引数は定義より優先され、いつ渡すかは `.claude/rules/context-efficiency.md`「サブエージェント委譲」の「モデル」に書いてある（`inherit` と書いた定義には、環境変数 `CLAUDE_CODE_SUBAGENT_MODEL` は効かない）
- `effort:` — `low` 〜 `max` で思考量を変える
- `maxTurns:` — 暴走防止のターン上限
- 「Output Budget」節 — 返却量の上限。情報が足りないなら増やし、要点が埋もれるなら削る
- 起動数の目安（1〜3 個）は各 Phase の起動数表（`phases/03-exploration.md` / `04-design.md` / `06-review.md`）で変えられる

組み込みの `Explore` / `Plan` エージェントで代用することもできる。違いは、テンプレートのエージェントは `CLAUDE.md` と `.claude/rules/` を読んだ上で動き、Project Context と返却量の既定値を持つこと（`Explore` / `Plan` は CLAUDE.md を読まない）。

## モデルの割り当て

Issue ごとに、着手するセッションのモデルと effort を変える任意の機能。ラベル `model:sonnet` / `model:opus` / `model:fable` を作ると有効になる（作成コマンドは README のクイックスタートの 4）。ラベルが無いプロジェクトでは、Issue ごとの割り当ては動かない（サブエージェントのモデルの選び方は、ラベルに関係なく上の「サブエージェントの調整」のとおり）。正本は `.claude/skills/issue-priority/model-assignment.md`。

- **付ける**: `/issue-priority` が `model:*` の無い Issue にラベル案を出し（確認のうえ付ける）、日次ルーティン `daily-triage` が同じ判定で付ける。付いているラベルは変えないので、人が付け替えたものが優先される
- **読む（対話）**: `/issue-start` が Phase 1 で、Issue のラベルと今のセッションのモデルを比べる。違えば、クラウドセッションではラベルのモデルの子セッションを立てて引き継ぎ（続きは、伝えられた URL の子セッションで行う）、ローカルでは 1 行で伝えてそのまま進む（`/model <名前>` で切り替えられる）。「このセッションで進めて」と言えば、引き継がない
- **読む（無人）**: `weekday-issue-start` が、選んだ Issue のラベルと自分のモデルを比べ、違えば子セッションに実装を引き継ぐ。スケジュールタスクのモデルは登録時に 1 つしか選べないので、一番多いラベル（多くは `model:sonnet`。無人実装の候補は、変更箇所と方針が本文で決まっている Issue のため）のモデルで登録しておくと、引き継ぎが減る
- **変える**: ラベルとモデル・effort の対応と、判定の条件は、`model-assignment.md`「ラベルとモデル」「判定」を書き換える。effort の既定値（`sonnet` と `opus` は `medium`、`fable` は `high`）は Anthropic の公開している目安に合わせてあり、PR の質を見て上げ下げする。子セッションを立てる呼び出しが effort の指定を受け付けない環境では、effort を外して立てるので、子セッションはそのモデルの既定の effort で動く。段を増やすなら、ラベルを作って表と判定に行を足す
- **引き継ぎの費用**: モデルが合わなかったセッションは、Issue を読んで子セッションを立てるところまでを使う。最初から合うモデルで始めれば掛からないので、`/issue-priority` の表のラベルを見て選ぶのが一番安い

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

Claude Code のクラウドセッション（claude.ai/code）では、`gh issue` / `gh pr` の大半が使う GraphQL API と、リポジトリをまたぐ検索 API が HTTP 403 で拒否される。GitHub MCP も無い場合は `gh api repos/{owner}/{repo}/...` の REST に読み替える（対応表は `.claude/skills/issue-start/pitfalls-cloud.md`「クラウドセッションでは gh の GraphQL 系が使えない」）。

MCP を使わない運用にする場合は `.mcp.json` を削除し、`settings.json` の `permissions.allow` の `mcp__github__*` を削る（deny の `mcp__github__merge_pull_request`・`mcp__github__enable_pr_auto_merge` は残す。クラウドセッションでは `.mcp.json` が無くても GitHub MCP が付く）。SKILL.md / phases 内の MCP 記述は「フォールバック」に従って `gh` に読み替えられるので、書き換えなくても動く。

ドキュメント参照（context7）・UI検証（Playwright）・Web検索 MCP は任意。接続しない場合、各 Phase の該当ステップは組み込みの `WebSearch` / `WebFetch` にフォールバックするか、スキップして「未検証」と報告する。

## コンテキスト予算の点検

セッション中に Claude が読む量は `.claude/rules/context-efficiency.md` が Claude 側に課している。一方、**環境側で毎ターン常駐するもの**（ツール定義・MCP・スキル・rules 自体）は人間が測って削る。

- **測る**: `/context` を実行し、常駐分（System prompt / System tools / MCP tools / MCP server instructions / Skills）と会話分（Messages）を分けて見る。`(deferred)` と付いた行は名前だけ登録されていて未ロードなので、合計には含まれない。常駐分は会話を始める前から毎ターン消費される固定費
- **MCP**: 接続したサーバーのツール定義は毎ターン載る。Claude Code のツール検索は既定で全 MCP ツールを deferred にし、必要になったときだけ schema を読むが、ツール名と server instructions は常駐する。`.mcp.json` は使うサーバーだけにし、`alwaysLoad: true`（常駐させる指定）は毎ターン使う少数に限る。`ENABLE_TOOL_SEARCH=auto` は「定義の合計がコンテキストウィンドウの 10% に達するまでは全部載せる」閾値モードで、既定（全 deferred）とは別物。仕様は [Scale with MCP tool search](https://code.claude.com/docs/en/mcp#scale-with-mcp-tool-search)
- **同期スキル・プラグイン**: claude.ai で有効にしたスキルやプラグインは、同じアカウントで使うローカルの Claude Code にも同期され、description が常駐する（`/context` の Skills に `claude.ai sync` として出る）。プロジェクトに無関係なものは `/plugin` の Installed タブで Claude Code 側だけ off にできる。逆に cloud session（claude.ai/code）は、ローカルやプロジェクトの `settings.json` で有効にしたプラグインを読み込まない（[Install and manage plugins](https://code.claude.com/docs/en/plugins/install)）
- **影響しないもの**: ブランチ数・コミット履歴・リポジトリ容量は、Claude が `git log --all` のように読み込まない限りコンテキストに影響しない。マージ済みブランチの掃除は衛生の話として別に扱う（GitHub の「Automatically delete head branches」と `git fetch --prune`）
- **いつ点検するか**: rules / skills / `.mcp.json` / `settings.json` を変えた PR と、応答が鈍くなった・指示を取りこぼすと感じたとき。常駐分が不自然に大きければ知見ボード（`.claude/rules/workflow-feedback.md`）に残す
- **rules の行数予算**: `CLAUDE.md` + `paths:` なし rules の合計（frontmatter を除く）は 1000 行以下を目安にする。超えたら棚卸しの合図として `refactor: rules 棚卸し` Issue を切り、`/doctor prompt-audit` で矛盾・古い記述を洗って統合・削除する（`.claude/skills/issue-start/pitfalls.md`・`pitfalls-cloud.md` の確認から 6 か月超の項目もここで見直す）。閾値を変えるときは理由をコミットメッセージに書く
  - **テンプレート元の CI 予算は 400 行で、利用プロジェクトの目安とは別**: テンプレート元では `tests/check-context-budget.py` が素のテンプレート分を 400 行で CI 検査し、超えると PR が赤くなる。数字を分けているのは、利用プロジェクトが固有の rules（`tech-stack.md` の中身やドメイン規約）に約 600 行を使えるよう枠を残すためと、テンプレート自体の肥大化を止めるため
  - **利用プロジェクトで同じチェックを入れる**: スクリプトをコピーし、先頭の `BUDGETS` のパスを自分のリポジトリに合わせ、`limit` を 1000 に変える。skill の各ファイルの大きさの検査（30,000 バイト未満。Bash の出力上限）も同じスクリプトにあるので、`SKILL_GLOB` を `.claude/skills/**/*.md` に変える。skill・ルーティンの合計の上限（`SKILL_TOTAL_MAX_BYTES`）は素のテンプレートに合わせた値なので、プロジェクトの現状値に余裕を足した値に変える（使わないなら、その検査を外す）

## settings.json の権限

`permissions.allow` はプロジェクトでよく使うコマンドに合わせて追加する（例: `Bash(npm run *)`, `Bash(cargo *)`, `Bash(pytest *)`）。書式は `Bash(コマンド *)`（`Bash(npm run:*)` と同義）。

`permissions.deny` の破壊的コマンド禁止（`rm -rf`, `git push --force`（引数の途中に来る形も含む）, `git reset --hard` 等）と `.env` の読み書き禁止は、どのプロジェクトでもそのまま残すことを推奨。deny は allow より先に評価されるので、allow で穴を開けることはできない。パスのルールは `Read(...)` / `Edit(...)` だけが評価される（`Write(...)` は無視されるので書かない。`Read` の deny は Edit / Write も塞ぐ）。

PR のマージと auto-merge も deny で止めている（`Bash(gh pr merge *)` と、GitHub MCP の `mcp__github__merge_pull_request`・`mcp__github__enable_pr_auto_merge`）。人の確認を PR のマージに置くためで、deny はどの権限モード（`bypassPermissions` も含む）でも効くので、無人実行（`weekday-issue-start` など）でも止まる。MCP のツールは名前で deny しているので、セッションのツール一覧から消える。対話のセッションで Claude にマージを頼みたいプロジェクトは、この 3 行を消す（同じ `settings.json` で動く無人実行のマージも、手順書の文面だけで止めることになる）。`.mcp.json` の GitHub MCP のサーバー名を `github` から変えたら、`mcp__<サーバー名>__merge_pull_request` のような行を足す（`github` の行は、クラウドセッションが付ける GitHub MCP の分として残す）。

Claude から `main` への直接の push は、deny ではなく PreToolUse hook（`.claude/hooks/validate-push-target.sh`）で止めている。マージを止めても、`main` に直接 push できれば人の確認を飛ばせるため。allow の `Bash(git push)`・`Bash(git push origin *)`・`Bash(git push -u origin *)` は、Issue ブランチへの push を確認なしで通すために残している。hook は push 先を解いて、`main`・`master` と `origin/HEAD`（`refs/remotes/<リモート>/HEAD`。クラウドセッションのクローンには無いことがある）が指すブランチに書く push を止める。止まる形は、`git push origin main`・`HEAD:main`・`heads/main`・`refs/heads/main`・`--delete main`・`:`・`'refs/heads/*'`・`--all`・`--mirror`、`main` にいるときの `git push`・`git push -u origin HEAD`、`git -C <dir> push`・`env -i git push`・`timeout 60 git push`・`/usr/bin/git push`、`$(...)` の中の push など（一覧は、このリポジトリの `tests/test-hooks.sh`）。クォートの中と heredoc の本文は、コマンドとして読まない（PR 本文やコミットメッセージに `git push origin main` と書いても止まらない）。変数やコマンド置換で組んだ refspec は確かめられないので止める。止まらないのは、push を別のシェルに渡す文字列（`sh -c '...'`・`bash -c`）、git の alias、push するスクリプトや make のターゲット、hook が読まない前置き（`sudo -u <user> git push` のように、オプションが語を取るもの）、`remote.<name>.push` の設定、人が端末から打つ push。同じコマンドで `cd` したときは、refspec の無い `git push` と `HEAD`・`@` の今のブランチを `cd` の前のディレクトリで読むので、`cd` 先が `main` なら止まらず、逆に `cd` の前が `main` なら Issue ブランチへの push でも止まる（`git -C <dir>` にすれば正しく読む）。ここまで止めるなら、GitHub のブランチ保護（ルールセットの「Require a pull request before merging」）を使う（人の直接 push も止まる）。Claude に `main` へ直接 push させたいプロジェクトは、`settings.json` の hooks からこの hook の登録を消す。

permission の deny はコマンド文字列の一致で判定するため、`git -C . push --force` や、`gh pr -R <owner/repo> merge`、`gh api` で PR のマージの API を直接呼ぶ書き方は素通りする。確実に止めたいなら hook で検査する。

## session-start-info.sh

「亡霊 worktree」（`git worktree remove` 後にディレクトリだけ残った状態）の検出と、テンプレート更新チェック（`.claude/template-version` と最新 Release タグの比較。最新タグは毎回取得し、取得失敗時だけ前回の結果を使う）が入っている。`claude --worktree` を使わないプロジェクトでは無害なので残してよいが、不要なら該当セクション（`Ghost worktree detection`）を削っても動く。末尾の「行動原則リマインダー」はプロジェクトの方針に合わせて書き換えてよい（短く保つ）。

SessionStart hook は `matcher` を指定していないので、起動・再開・`/clear`・コンパクション後のすべてで走り、バナーを再注入する。

## 無人実行（スケジュール実行）で回す場合

`/issue-start` は Phase 1 の不足確認・Phase 4 の設計承認・スコープ外問題の起票・GitHub 上の操作だけで終わる Issue の適用前・Phase 8 の知見ボード追記とテンプレート元への還元でユーザーの Y/E/N を待つ設計になっている（`.claude/skills/issue-start/SKILL.md`「全体ルール」、`.claude/rules/workflow-feedback.md`「自動化しないこと」）。Claude Code のスケジュールタスクから「Open Issue を 1 件選んで PR 作成まで無人で回す」日次ルーティンを運用する場合は、テンプレートの任意の機能 `weekday-issue-start` を使う（セットアップは [routines-guide.md](routines-guide.md)「`weekday-issue-start` を使う場合」）。rules / skill 本文は変えず、ルーティンの手順書の側で確認ポイントを読み替える。無人実行でも「テンプレート元への無人起票・無人更新はしない」は維持する。

- **確認ポイントの読み替え・安全策**: 正本は `.claude/routines/weekday-issue-start.md`（「1. 事前点検（安全弁）」の Open PR の上限・conflict の解消・取り残しブランチの報告、「4. 実装」の読み替え表と検証）。人のゲートは PR のマージに置き、マージ・auto-merge・force push はしない
- **対象 Issue の選定**: 正本は `.claude/skills/issue-priority/routine-candidates.md`（人が `routine-ok` を付けた Issue だけを候補にし、`/issue-priority` の「ルーティン向け」と同じ条件で選ぶ）
- **自前で無人実行のルーティンを組む場合**も、上の 2 つを読んで同じ読み替えと条件を使う。とくに、決められない分岐で `needs-decision` のようなラベルを付けて次回の選定から外すこと、手順書・規約から人の確認を外す・弱める変更を自分で承認しないこと、自分の Open PR の数に上限を置くことは外さない

### 起票側のルーティンを併用する場合

メモ inbox・知見ボードからの起票と priority の付与は、テンプレートに日次ルーティン `daily-triage` の手順書がある（`.claude/routines/daily-triage.md`。セットアップは [routines-guide.md](routines-guide.md)）。下の点はそこに入れてある。自前で起票側のルーティンを組むなら、同じく次を入れる:

- 1 回の起票件数に上限を置く
- 起票前に Open / Closed の両方で重複チェックする
- 着手可能な Open Issue が一定数以上なら自動起票を見送る（バックログの単調増加を防ぐ）
- コードスキャンなど仕様の推測を含む系統の Issue は「## 未確定事項」に「要ユーザー確認」と書くか、ラベルで人のトリアージを挟む

## 知見ボードを使わない場合

小規模・短期のプロジェクトで知見ボード運用が過剰なら：

1. `.claude/rules/workflow-feedback.md` を削除
2. `CLAUDE.md` の「詳細規約」テーブルから該当行を削除
3. `SKILL.md` の「ワークフロー改善の知見ボード」節と `phases/08-issue-recording.md` の「5. ワークフロー改善余地」「6. テンプレート元への還元」節を削除
4. 知見ボード作成用の Issue テンプレート `.github/ISSUE_TEMPLATE/workflow-feedback.md` を削除（知見ボード Issue を既に作っていればクローズする）

## テンプレート元への還元 / 更新チェックを止める・向け先を変える

知見ボードは使うが、社外（このスターターキット）への還元はしない運用にする場合：

1. `.claude/rules/workflow-feedback.md` の「テンプレート元への還元」節を削除し、`phases/08-issue-recording.md` 手順 5 の候補フォーマットとコメント本文テンプレートから `還元先` 行を消す
2. `phases/08-issue-recording.md` の「6. テンプレート元への還元」節を削除
3. `SKILL.md` の知見ボード節と `.github/ISSUE_TEMPLATE/workflow-feedback.md` の「運用」にある「テンプレート元への還元」の箇条書きを削除

更新チェックも止める場合は、さらに `.claude/template-version` を削除する（SessionStart hook はファイルが無ければ何も出さない）。`phases/01-issue-analysis.md` の「0.5 テンプレート更新チェック」節と `phases/01-template-update-check.md`、`workflow-feedback.md` の「テンプレート元の情報」「テンプレート更新の取り込み」節、`.claude/skills/template-update/` も削ってよい。

更新チェックのネットワークアクセスだけ避けたい（社内プロキシ等）場合は `session-start-info.sh` の `Template update check` セクションを削るか、`.claude/template-version` を削除する。

フォークした独自テンプレートに向けたい場合は、削除ではなく `.claude/template-version` の `repo` を書き換える（[upstream-feedback.md](upstream-feedback.md)「フォークして独自テンプレートにする場合」）。

## 変更後の点検

CLAUDE.md や rules を大きく変えたら、`/context` で読み込まれているファイルと消費量を確認し、`/doctor prompt-audit` で冗長・矛盾した指示が無いか点検する（`/doctor` は Claude からは呼べないので、Claude に点検させるときは `claude-api` skill に `prompt-audit <パス>` を渡させる。`template/.claude/skills/issue-start/pitfalls.md`「`/doctor` は Claude から呼べない」）。常駐分の内訳と削り方は「コンテキスト予算の点検」。hooks を変えたら `tests/test-hooks.sh` を通す。
