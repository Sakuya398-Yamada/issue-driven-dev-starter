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

## Issue の粒度を調整する

Issue の粒度は `.claude/rules/git-conventions.md` の「粒度」表で定義しており、`/issue-plan`（分割・起票）と `/issue-start` Phase 1（粒度チェック）の **両方が同じ表を参照する**。調整はこの表だけでよい：

- **作業量の目安**（既定: 変更ファイル 10 個以内・差分 300 行以内）: チームの PR レビュー負荷に合わせて増減する。小規模な個人プロジェクトなら大きめ、複数人レビューなら小さめが目安
- **「分ける／分けない」表**: プロジェクト特有の判断（例: 「DB マイグレーションは必ず単独 Issue」「UI と API は縦に切る」）を行として足す
- **親Issue を作る閾値**（既定: 3 件以上）: 「依存関係と親Issue」節の数値を変える

Phase 1 の粒度チェックで分割提案が多すぎる／少なすぎると感じたら、閾値を変えるより先に表の文言が曖昧でないかを疑い、知見ボードに残す。

## `/issue-plan` を使わない場合

Issue を常に手書きする運用なら `.claude/skills/issue-plan/` を削除し、`CLAUDE.md` の「開発フロー」と `git-conventions.md`「依存関係と親Issue」の `/issue-plan` への言及を消す。粒度の表自体は `/issue-start` Phase 1 のチェックで使うので残しておく。

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

`session-start-info.sh` には「亡霊 worktree」（`git worktree remove` 後にディレクトリだけ残った状態）の検出と、テンプレート更新チェック（`.claude/template-version` と最新 Release タグの比較。前節参照）が入っている。Claude Code の worktree 機能を使わないプロジェクトでは無害なので残してよいが、不要なら該当セクション（`Ghost worktree detection` 以降）を削っても動く。

## 知見ボードを使わない場合

小規模・短期のプロジェクトで知見ボード運用が過剰なら：

1. `.claude/rules/workflow-feedback.md` を削除
2. `CLAUDE.md` の Memory Imports から該当行を削除
3. `SKILL.md` の「ワークフロー改善余地の知見ボード」節と `phases/08-issue-recording.md` の「5. ワークフロー改善余地」「6. テンプレート元への還元」節を削除

## テンプレート元への還元 / 更新チェックを止める・向け先を変える

知見ボードは使うが、社外（このスターターキット）への還元はしない運用にする場合：

1. `.claude/rules/workflow-feedback.md` の「テンプレート元への還元」節を削除し、記入フォーマットの `**還元先**` 行を消す
2. `phases/08-issue-recording.md` の「6. テンプレート元への還元」節を削除
3. `SKILL.md` の知見ボード節にある「テンプレート元への還元」の箇条書きを削除

更新チェックも止める場合は、さらに `.claude/template-version` を削除する（SessionStart hook はファイルが無ければ何も出さない）。`phases/01-issue-analysis.md` の「0.5 テンプレート更新チェック」節と `workflow-feedback.md` の「テンプレート元の情報」「テンプレート更新の取り込み」節も削ってよい。

更新チェックのネットワークアクセスだけ避けたい（社内プロキシ等）場合は `session-start-info.sh` の `Template update check` セクションを削るか、`.claude/template-version` を削除する。

フォークした独自テンプレートに向けたい場合は、削除ではなく `.claude/template-version` の `repo` を書き換える（[upstream-feedback.md](upstream-feedback.md)「フォークして独自テンプレートにする場合」）。
