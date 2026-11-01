# テンプレート更新の手動対応

テンプレートの新しい版を取り込むときに、`/template-update` の 3-way マージだけでは揃わない手作業を、版ごとに書く（新しい版が上）。GitHub の Release notes に足す「手動対応」と同じ中身を、ここにも置く。Release notes を API で読めない環境（テンプレート元がセッションに付いていないクラウドセッションなど）でも、テンプレート元のクローンから `git show vNEW:docs/upgrade-notes.md` で読めるようにするため（`HEAD` ではなく vNEW のタグで読む。クローンの `HEAD` は古いことも、まだリリースされていない記述を含むこともある）。

`vOLD` から `vNEW` に上げるときは、`vOLD` より新しく `vNEW` 以下の版の節をすべて読む。ここに節の無い版には、手動対応は無い。

## v2.4.2

v2.4.1 以前から取り込むとき。

**Claude Code 版**: 手動対応は無い。この版は Copilot 版（`template-copilot/`）をこのリポジトリから外しただけで、`template/` の中身は変わっていない。

**Copilot 版**: この版から、Copilot 版はこのリポジトリに無い。v2.4.1 の時点の中身を、履歴とタグ（v2.4.1 以前の全版）ごと [issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot) に切り出した。この版を `/template-update` で取り込むと、`template-copilot/` の全ファイルが「vNEW で削除」になる。**取り込まずに**、テンプレート元を切り替える。切り替えないと、更新チェックがこのリポジトリのタグと比べ続け、Claude Code 版の版が出るたびに更新用 Issue の起票を提案する。

1. `.github/template-version` の `repo` の行を `repo=Sakuya398-Yamada/issue-driven-dev-starter-copilot` にする。`version` はそのままでよい（新しいリポジトリにも同じ版のタグがある）
2. `.github/instructions/workflow-feedback.instructions.md`「テンプレート元の情報」のリンク（`[issue-driven-dev-starter](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter)`）を、新しいリポジトリ（`[issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot)`）にする。プロジェクトで別のテンプレート元に書き換えていたら、どちらもそのままでよい
3. 新しいリポジトリの最新タグを確かめる。`version` と同じなら、それで終わり。新しければ、Phase 1 手順 0.5 のとおり、その版の更新用 Issue を起票して取り込む（v2.4.1 より前の版を使っていたプロジェクト）

```bash
grep '^repo=' .github/template-version
git ls-remote --tags --refs --sort=-v:refname https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot.git 'v*' | head -n 1 | awk -F/ '{print $NF}'
```

- 更新用 Issue（`refactor: テンプレートを v2.4.2 に更新`）から来たときは、その PR を手順 1・2 の書き換えだけにする。`.github/template-version` の `version` は上げない（v2.4.2 は新しいリポジトリには無い版のため）
- Copilot 版の気づきの還元先（Phase 8 手順 6）も、`repo` を書き換えれば新しいリポジトリになる。新しいリポジトリでは、Copilot 版の改善は止めている（Issue は受け付ける）

## v2.4.0

v2.3.x 以前から取り込むとき。

`/template-update` の 3-way マージで、テンプレートの中身はそのまま揃う。手作業が要るのは、次のうち当てはまるものだけ。

**新しいファイル**

| 追加したもの | ファイル |
|---|---|
| 依存の付け方・読み方・外し方（#195） | `.claude/skills/issue-start/dependencies.md` |
| 着手できる Issue の一覧のスクリプト（#196） | `.claude/scripts/issue-ready.sh` |

- どちらも「project にない」として置かれる。スクリプトは Write で置かれるので実行権限が付かないことがある。README のとおり `bash .claude/scripts/issue-ready.sh` と `bash` を付けて呼べば、そのままでよい

**既存の Issue の依存（#195）**

v2.4.0 から、依存は本文の「## 関連Issue」の `依存: #N` と、GitHub の依存関係（blocked by）の両方に書く。取り込む前に本文だけで書いた依存は、`issue-ready.sh` の「注意」に `本文だけにある依存: #N` として出る。どちらか一方にあれば依存とみなすので、揃えなくても「着手できる」「依存待ち」の判定は変わらない。「注意」を消したいときは、Open Issue の本文の依存に blocked by を付ける（`gh` と `jq` を使う。付ける前に、1 行目だけで対象を確かめる）:

```bash
# 対象の一覧（「#B は #A に blocked by される」の組）
bash .claude/scripts/issue-ready.sh --json | jq -r '.issues[] | .number as $b | .body_only[] | "\($b) \(.)"'

# 上の一覧に blocked by を付ける
bash .claude/scripts/issue-ready.sh --json | jq -r '.issues[] | .number as $b | .body_only[] | "\($b) \(.)"' |
  while read -r b a; do
    id=$(gh api "repos/{owner}/{repo}/issues/$a" --jq .id)
    gh api -X POST "repos/{owner}/{repo}/issues/$b/dependencies/blocked_by" -F issue_id="$id" --silent && echo "#$b ← #$a"
  done
```

- 既に付いている組は `422`（`Target issue has already been taken`）で失敗するが、付いているのでそのままでよい

**プロジェクト独自の記述**

- 本文の `依存: #N` を読んで着手順や優先度を決める独自の skill・定期実行のプロンプトがあれば、blocked by も見るか、`issue-ready.sh --json` の `status` / `blocked_by` / `blocking` を使う形に変えられる（エージェントに全 Issue の本文を読ませなくてよくなる）
- `/issue-plan` がバグの起票で、本文の「## 関連Issue」に `由来: #N` を書くようになった（#197）。「## 関連Issue」の行を読む独自の処理があれば、`依存:` と `由来:` を取り違えないか確かめる（`issue-ready.sh` は `依存:` で始まる行だけを読む）
- `.claude/settings.json`・`.mcp.json` の変更は無い

## v2.3.3

v2.3.2 以前から取り込むとき。

v2.3.3 では、Bash の出力上限（30,000 バイト）に余裕を持たせるため、skill のファイルのうち条件付きの中身を新しいファイルに移した（#207）。`/template-update` の 3-way マージでは、移した分は元のファイルから消える差分として当たる。新しいファイルは「project にない」として置かれる。だから、テンプレートの中身はそのまま揃う。手作業が要るのは、プロジェクト側でこれらに手を入れていたときだけ。

| 移したもの | 移した先（新規） | 手作業 |
|---|---|---|
| `.claude/skills/issue-start/pitfalls.md` のうち、条件が Claude Code のクラウドセッションの 9 項目（下記） | `.claude/skills/issue-start/pitfalls-cloud.md` | 下の 1〜3 |
| `phases/01-issue-analysis.md` 手順 0.5 の確認の形式・起票の手順・キャッシュと Checkout の注記 | `phases/01-template-update-check.md` | 手を入れていたら、移った先に当て直す |
| `phases/01-issue-analysis.md`「オープンな旧 PR／既存ブランチがある場合」 | `phases/01-existing-pr-branch.md` | 同上 |
| `phases/05-implementation.md`「起動時に読まれる設定の検証」の手順 | `phases/05-startup-config-check.md` | 同上 |

pitfalls で要る手作業:

1. 下の 9 項目に手を入れていた場合: `pitfalls.md` でコンフリクトになる。手を入れた内容を、`pitfalls-cloud.md` の同じ見出しに移す
2. プロジェクトで足した項目のうち、条件がクラウドセッションのもの: `pitfalls-cloud.md` に移す。新しい置き場所は `.claude/rules/documentation-policy.md`「ハマりどころの書き先」に書いてある。移さなくても動くが、`pitfalls.md` が大きくなる
3. プロジェクト独自のファイルが、9 項目を `pitfalls.md`「<見出し>」で参照している場合: `pitfalls-cloud.md` に付け替える。テンプレートのファイルの参照は、3-way マージで付け替わる。取り込み後、次のコマンドが何も出さなければよい

```bash
grep -rnF -e 'pitfalls.md`「クラウドセッション' -e 'pitfalls.md`「フォアグラウンドで起動したサブエージェント' --include='*.md' .
```

移した 9 項目の見出し:

- クラウドセッションでは gh の GraphQL 系が使えない
- クラウドセッションでは `gh api --paginate` が 2 ページ目で止まる
- クラウドセッションで `gh api` から本文やコメントを書き込むと、署名フッターが末尾に付く
- クラウドセッションの git プロキシは、別ブランチへの push を通し、ブランチの削除を通さない
- クラウドセッションの auto mode では、allow に当たる Bash も分類器が判定する
- クラウドセッションにリポジトリを複数付けて開始すると、settings.json が読まれない
- フォアグラウンドで起動したサブエージェントも、2 分ほどでバックグラウンドに回される
- クラウドセッションの Stop hook は、止まるたびに未コミットの変更の commit / push を 1 度だけ求める
- クラウドセッションでコンテナが再起動すると、バックグラウンドのサブエージェントの報告が届かない

そのほか:

- `.claude/hooks/session-start-info.sh` のバナーの `⚠` の行が、`local … → latest …` から `Local … → Latest …` になった（#213）。この行を文字列で読んでいる、プロジェクト独自のスクリプトがあれば追従する

## v2.0.0

v1.x から取り込むとき。[migration-v2.md](migration-v2.md) に従う。
