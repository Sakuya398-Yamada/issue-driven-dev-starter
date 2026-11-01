# Issue の依存の付け方と読み方

`/issue-start` と `/issue-plan` から参照される補助ファイルで、常駐しない。Issue 間の依存（後続の Issue B が、先行の Issue A の完了を待つ）は、次の 2 か所に同じ内容で書く。

- B の本文の「## 関連Issue」の `依存: #<A>`: 人が本文だけで読める。`gh` が無い環境でも書ける
- GitHub の依存関係（B が A に blocked by される）: 機械が読める。Issue 一覧の `is:blocked` / `blocked-by:<A>` でも絞り込める

GitHub MCP には依存関係を読み書きするツールが無く、`issue_read` / `list_issues` の結果にも出ないので、依存関係は `gh api` の REST で扱う。REST なので、GraphQL 系が使えない環境（Claude Code のクラウドセッションなど）でも使える（`gh issue create --blocked-by` は GraphQL なので使わない）。

## 付け方

B を起票し、本文に `依存: #<A>` を書いたら、B に「A に blocked by される」を付ける。渡すのは A の Issue 番号ではなく、REST の Issue の `id`。番号を渡すと別の Issue を指すか、見つからずに失敗する。

```bash
id=$(gh api "repos/{owner}/{repo}/issues/<A>" --jq .id)
gh api -X POST "repos/{owner}/{repo}/issues/<B>/dependencies/blocked_by" -F issue_id="$id"
```

- 1 つの Issue に付けられる blocked by は 50 件まで
- 既に付いていれば `422`（`Target issue has already been taken`）で失敗する。付いているので、そのままでよい
- `gh` が無い環境では本文だけを書き、GitHub の画面で付けるようユーザーに案内する（B の右のサイドバーの「Relationships」→「Mark as blocked by」で A を選ぶ。リポジトリの triage 以上の権限が要る）

## 読み方

B の依存は、本文の `依存: #N` と blocked by の両方から集める。

```bash
gh api "repos/{owner}/{repo}/issues/<B>/dependencies/blocked_by" --jq '.[] | [.number, .state, .title] | @tsv'
```

- 両方に同じ番号があれば、その Issue の状態（`state`）で完了しているかを見る
- 片方にしか無い番号も依存とみなす。そのうえで食い違っていることをユーザーに伝え、揃えるかを聞く（本文に足すなら `issue_write` の `update`、blocked by に足すなら「付け方」、blocked by から外すなら「外し方」）
- `gh` が無い環境では本文の `依存: #N` だけで判定し、blocked by は見ていないことを添える

## 外し方

依存が要らなくなったら、本文の `依存: #<A>` を消し、blocked by も外す。外すときも A の `id` を使う。

```bash
id=$(gh api "repos/{owner}/{repo}/issues/<A>" --jq .id)
gh api -X DELETE "repos/{owner}/{repo}/issues/<B>/dependencies/blocked_by/$id"
```
