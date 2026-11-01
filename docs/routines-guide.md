# 定期ルーティンのセットアップ（任意）

Claude Code のクラウドのスケジュールタスク（Routines）で、Issue の棚卸しを毎日回すための手順。使わないなら何もしなくてよい。手順書（`.claude/routines/`）を置いてあっても、スケジュールタスクに登録しなければ動かない。

> **research preview**: スケジュールタスク（Routines）は、2026-04 に research preview として公開された機能で、動作・制限・API が変わり得る（[Introducing routines in Claude Code](https://claude.com/blog/introducing-routines-in-claude-code)）。この手順は 2026-11 時点の仕様に合わせてある。手順どおりに登録できないときは、Claude Code の [クラウドセッションの docs](https://code.claude.com/docs/en/claude-code-on-the-web) と登録画面を確かめる。

## 前提

- Claude Code の有料プラン（Pro / Max / Team / Enterprise）で、Claude Code on the web を使える
- このリポジトリを claude.ai/code から使える（GitHub の連携が済んでいる）
- ルーティンの実行も、プランの使用量に数えられる

## 入っているルーティン

| taskId | 何をするか | 書き込み |
|--------|-----------|---------|
| `daily-triage` | メモ inbox と知見ボードから Issue を起票し、`priority:*` の無い Issue に priority を付け、着手順のおすすめを実行ログに出す | 起票、起票した元のコメントへの ✅ の印、`priority:*` の付与、実行ログへのコメント |

- ルーティンの書き込みは、`.claude/rules/routines.md`「事前に承認した書き込み」の範囲だけ。登録することが、この範囲の書き込みを承認することになる
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

`.claude/rules/routines.md`「ルーティンの一覧」の `<タイムゾーン>` を、IANA のタイムゾーン名（例: `Asia/Tokyo`）で埋める。時刻を変えるなら、`.claude/routines/daily-triage.md` の frontmatter の `schedule` と、一覧の cron を揃えて直す。

### 4. main に入れる

ルーティンは、実行のたびに `origin/main` の手順書と `.claude/rules/routines.md` を読む。2・3 の変更を main にマージしてから登録する。

### 5. スケジュールタスクに登録する

claude.ai/code の Routines で新しいスケジュールタスクを作る（CLI の `/schedule` からも作れる）。

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

### 6. 1 回流して確かめる

登録したスケジュールタスクを、登録画面から手で 1 回実行する（手で実行するボタンが無ければ、最初の時刻を待つ）。実行ログ Issue に `## daily-triage 実行報告（YYYY-MM-DD）` のコメントが 1 件付けば、動いている。最初にメモ inbox に 1 件書いておくと、起票と ✅ の印まで確かめられる。

## 運用

- **実行報告を読む**: 人が動く項目は、「要追記」（メモが曖昧で起票できなかった）、「要還元（ユーザー）」（テンプレート元への還元が要る知見）、「取り込み待ち」（還元済みで、テンプレート更新を待っている知見）、「見送り」（件数の上限を超えた分。次の実行で続きを行う）
- **手順を変える**: PR で `.claude/routines/daily-triage.md` を直す。登録側は触らない（マージした次の実行から効く）。件数の上限（起票 10・知見の昇格 3・priority 10・バックログ 25）は既定値で、手順書の中で変えてよい
- **止める**: 登録画面でスケジュールタスクを無効にするか削除する。手順書は残しておいてよい

## 困ったとき

- 登録側のプロンプトが呼び出し文のままか: `.claude/rules/routines.md`「呼び出し文のままかを確かめる」
- 登録が消えた: `.claude/rules/routines.md`「消えたら作り直す」
- クラウドセッションに特有のハマりどころ（`gh` の GraphQL 系が使えない、`--paginate` が止まる、署名フッターが付く、など）: `.claude/skills/issue-start/pitfalls-cloud.md`
