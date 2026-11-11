# 定期ルーティンのセットアップ（任意）

Claude Code のクラウドのスケジュールタスク（Routines）で、Issue の棚卸し・起票を定期的に回すための手順。使わないなら何もしなくてよい。手順書（`.claude/routines/`）を置いてあっても、スケジュールタスクに登録しなければ動かない。

> **research preview**: スケジュールタスク（Routines）は、2026-04 に research preview として公開された機能で、動作・制限・API が変わり得る（[Introducing routines in Claude Code](https://claude.com/blog/introducing-routines-in-claude-code)）。この手順は 2026-11 時点の仕様に合わせてある。手順どおりに登録できないときは、Claude Code の [クラウドセッションの docs](https://code.claude.com/docs/en/claude-code-on-the-web) と登録画面を確かめる。

## 前提

- Claude Code の有料プラン（Pro / Max / Team / Enterprise）で、Claude Code on the web を使える
- このリポジトリを claude.ai/code から使える（GitHub の連携が済んでいる）
- ルーティンの実行も、プランの使用量に数えられる

## 入っているルーティン

| taskId | 何をするか | 書き込み |
|--------|-----------|---------|
| `daily-triage` | メモ inbox と知見ボードから Issue を起票し、`priority:*` の無い Issue に priority を付け、着手順のおすすめを実行ログに出す | 起票、メモ inbox・知見ボードのコメントへの ✅ の印、`priority:*` の付与、実行ログへのコメント |
| `weekly` | コードスキャン（対象と観点はプロジェクトで書く）と、プロジェクト固有の系統から Issue を起票し、priority の付け直しの案を実行ログに出す | 起票（`priority:*` は付けない）、実行ログへのコメント。ラベルの付け直しはしない |
| `weekday-issue-start`（任意） | 人が `routine-ok` を付けた Issue を 1 件選び、`/issue-start` の手順で PR の作成まで無人で進める（マージは人） | Issue ブランチの push と PR の作成、自分の PR への main の取り込み、候補の Issue へのコメントと `needs-decision`、実行ログへのコメント |

- ルーティンの書き込みは、`.claude/rules/routines.md`「事前に承認した書き込み」の範囲だけ。登録することが、この範囲の書き込みを承認することになる
- 使うものだけを登録する。`weekly` は `daily-triage.md` のバックログの数え方を読むので、`daily-triage` を登録しなくても `daily-triage.md` は消さない。起票した Issue の priority は次の `daily-triage` が付けるので、`weekly` だけを登録するときは priority を人が `/issue-priority` で付ける
- テンプレート汎用（未還元）の知見は、利用プロジェクトに起票しない。実行報告の「要還元」に挙がるので、人が `/issue-start` Phase 8 手順 6 の形でテンプレート元に還元する

## セットアップ

### 1. クイックスタートを済ませる

README のクイックスタートの 4（ラベル）と 5（知見ボード Issue）が済んでいること。`daily-triage` は `priority:*` ラベルと、知見ボードの番号（`.claude/rules/workflow-feedback.md`「知見ボードIssue」）を使う。

### 2. 管理用の Issue を作る

```bash
gh issue create --title "meta: ルーティン実行ログ" --label meta \
  --body "定期ルーティンの実行報告を 1 実行 1 コメントで残す常時 Open Issue。運用は .claude/rules/routines.md 参照。"
```

```bash
gh issue create --title "meta: メモ inbox" --label meta \
  --body "思いついたことを 1 件 1 コメントで書く常時 Open Issue。日次ルーティン daily-triage が Issue に整えて起票し、元のコメントに ✅ の印を付ける。"
```

発行された番号を、`.claude/rules/routines.md`「管理用の Issue」の `#<実行ログIssue番号>` と `#<メモinboxIssue番号>` に書く。

### 3. タイムゾーンを決める

`.claude/rules/routines.md`「ルーティンの一覧」の `<タイムゾーン>` を、IANA のタイムゾーン名（例: `Asia/Tokyo`）で埋める。時刻を変えるなら、`.claude/routines/<taskId>.md` の frontmatter の `schedule` と、一覧の cron を揃えて直す。

### 4. `weekly` を使うなら、コードスキャンの対象と観点を書く

`.claude/routines/weekly.md`「系統1: コードスキャン」の `<対象のディレクトリ>` と `<観点>` を、このプロジェクトに合わせて書く（書くまでは、この系統は飛ばされる）。外部の仕様の監視のように、このプロジェクトだけの起票の系統があれば「系統2」に足す。コードスキャンで起票される Issue には、`## 未確定事項` に人のゲートの 1 行（`[要確認] コードスキャンによる自動起票のため…`）が入る。内容を確かめたら、人がその行を消す

### 5. main に入れる

ルーティンは、実行のたびに `origin/main` の手順書と `.claude/rules/routines.md` を読む。2〜4 の変更を main にマージしてから登録する。

### 6. スケジュールタスクに登録する

使うルーティンごとに、claude.ai/code の Routines で新しいスケジュールタスクを作る（CLI の `/schedule` からも作れる）。下の表は `daily-triage` の例で、`weekly` も同じ形（名前・cron・taskId を `weekly` のものにする）。

| 項目 | 入れるもの |
|------|-----------|
| 名前 | `.claude/routines/daily-triage.md` の frontmatter の `title` |
| リポジトリ | このリポジトリ |
| スケジュール | 一覧の cron（`CRON_TZ=Asia/Tokyo 0 19 * * *` なら、日本時間の毎日 19:00）。画面で時刻を選ぶ形なら、同じ時刻にする |
| プロンプト | `.claude/rules/routines.md`「呼び出し文」の `<taskId>` を `daily-triage` に埋めたもの |

プロンプトは手で書き写さず、リポジトリ直下で書き出して貼る（同じ形は `.claude/rules/routines.md`「消えたら作り直す」にもある）:

```bash
sed 's/\r$//' .claude/rules/routines.md | awk '/^```text$/ { f = 1; next } f && /^```$/ { exit } f' | sed 's/<taskId>/daily-triage/g'
```

登録したら、スケジュールタスクの ID（`trig_...`）を `.claude/rules/routines.md`「ルーティンの一覧」に書く。

### 7. 1 回流して確かめる

登録したスケジュールタスクを、登録画面から手で 1 回実行する（手で実行するボタンが無ければ、最初の時刻を待つ）。実行ログ Issue に `## <taskId> 実行報告（YYYY-MM-DD）` のコメントが 1 件付けば、動いている（起票が 0 件の実行も報告を投稿する）。`daily-triage` は、最初にメモ inbox に 1 件書いておくと、起票と ✅ の印まで確かめられる。

## `weekday-issue-start` を使う場合

人が `routine-ok` ラベルを付けた Issue を、毎日 1 件ずつ無人で PR まで進める。既定では使わない（登録しない）。上の 1〜3 と 5 に加えて、次を行う。

1. **ラベルを作る**: `routine-ok` と `needs-decision`（作成コマンドは README のクイックスタートの 4）。`routine-ok` があると、`/issue-priority` と `daily-triage` が「ルーティン向け」の区分と「`routine-ok` を付ける候補」を出すようになる
2. **検証のコマンドを書く**: `.claude/rules/tech-stack.md`「よく使うコマンド」に、テスト・リント・型チェックのコマンドを書く。無人実装は、PR を作る前にこれを必ず通す（未記入なら、検証のコマンドが未記入と PR に書いて進む）。依存の導入が要るなら、そのコマンドも同じファイルに書く
3. **UI の確認の手段を書く**: `.claude/routines/weekday-issue-start.md`「検証と UI の確認」の `<手段>` を埋める（例: Playwright MCP。UI が無ければ「なし」）。未記入なら、UI に関わる変更は「UI未検証」と PR に書かれる
4. **登録する**: 「6. スケジュールタスクに登録する」と同じ形で、`weekday-issue-start` を登録する。時刻は `daily-triage` より後にする（`daily-triage` が付けた priority を、その日の選定に効かせるため）。一覧のスケジュールタスク ID の欄も書く
5. **任せる Issue に `routine-ok` を付ける**: 付けるのは人だけで、ルーティンは付けも外しもしない。候補にしやすいのは、変更箇所と方針が本文で決まっている Issue（`/issue-priority` と `daily-triage` が「無人向き」として挙げる）。条件は `.claude/skills/issue-priority/routine-candidates.md`「候補条件」

運用で気をつけること:

- **人のゲートは PR のマージ**。ルーティンはマージも auto-merge もしない。自分の Open PR が上限（既定 5 件）に達すると、新しい Issue を選ばない
- **`needs-decision`**: ルーティンが人の決定を待つ Issue に付く（要件の分岐を決められなかった、依存先が完了せずに閉じた、など。理由は Issue のコメントにある）。人が決めて、決定をコメントに書き、`needs-decision` を外すと、また候補になる。依存先が理由なら、本文の `依存:` と blocked by も直す（残すと、次の実行でまた付く）。対話の `/issue-start` で決めた場合は、その手順でラベルが外れる
- **着手の印**: 人がローカルで `routine-ok` の Issue を `/issue-start` すると、Phase 2 で Issue に「## 着手」の印が付き、ルーティンはその Issue を選ばない。やめるときは、印の見出しを「## 着手（取り下げ）」に書き換える
- **手順書を変える PR は、マージした次の実行から効く**。無人実装が自分の手順書を書き換える Issue を選ぶこともあるので、ルーティンの手順書・`/issue-priority` を変える Issue には、`routine-ok` を付けないのが安全

## モデルの割り当てを使う場合

ラベル `model:sonnet` / `model:opus` / `model:fable` を作ると（README のクイックスタートの 4）、`daily-triage` が `model:*` の無い Issue にラベルを付け、`weekday-issue-start` が、選んだ Issue のラベルと自分のモデルが違うときに、ラベルのモデルの子セッションへ実装を引き継ぐ。仕組みと変え方は [customization.md](customization.md)「モデルの割り当て」。

- **スケジュールタスクのモデル**: モデルと effort は、スケジュールタスクごとに登録画面で 1 つ選ぶ（実行ごとには変えられない）。`weekday-issue-start` は、一番多いラベルのモデルで登録する
- **引き継いだ実行の見え方**: スケジュールタスクの履歴には、Issue を選んで引き継いだところまでのセッションが出る。実装と実行報告は、子セッション（タイトルが `weekday-issue-start: #<番号> …`）にある。実行報告の「モデル」の行に、ラベルと実装したモデルが書かれる。子セッションが報告の前に止まると、実行ログにはその日のコメントが付かない（引き継いだことは、スケジュールタスクの履歴のセッションの最後に出る）。ブランチを push したあとなら、次の実行の「取り残しブランチ」に出る
- **引き継げなかったとき**: ルーティンは自分のモデルのまま実装し、理由を実行報告の「モデル」の行と PR 本文に書く

## 運用

- **実行報告を読む**: 人が動く項目は、「要追記」（メモが曖昧で起票できなかった）、「要還元（ユーザー）」（テンプレート元への還元が要る知見）、「取り込み待ち」（還元済みで、テンプレート更新を待っている知見）、「見送り」（件数の上限を超えた分。次の実行で続きを行う）
- **手順を変える**: PR で `.claude/routines/<taskId>.md` を直す。登録側は触らない（マージした次の実行から効く）。件数の上限（`daily-triage` は起票 10・知見の昇格 3・priority 10・バックログ 25、`weekly` は起票 10・コードスキャン 3）は既定値で、手順書の中で変えてよい
- **止める**: 登録画面でスケジュールタスクを無効にするか削除する。手順書は残しておいてよい

## 困ったとき

- 登録側のプロンプトが呼び出し文のままか: `.claude/rules/routines.md`「呼び出し文のままかを確かめる」
- 登録が消えた: `.claude/rules/routines.md`「消えたら作り直す」
- クラウドセッションに特有のハマりどころ（`gh` の GraphQL 系が使えない、`--paginate` が止まる、署名フッターが付く、など）: `.claude/skills/issue-start/pitfalls-cloud.md`
