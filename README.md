# Issue駆動開発スターターキット for Claude Code

GitHub Issue を唯一の情報源として Claude Code に開発を進めさせる **Issue駆動開発ワークフロー** のテンプレート集。
`/issue-start #N` の一言で「Issue分析 → ブランチ作成 → 探索 → 設計（承認）→ 実装・検証 → レビュー → PR作成 → Issueへの記録」まで一気通貫で回せる。その入口となる Issue の分割・起票も `/issue-plan` で同じ粒度規約に沿って行える。

実プロジェクトで Issue を回して育てたワークフローを、任意のプロジェクトで使えるように汎用化したもの。Claude Code の現行仕様（`.claude/rules/` の自動読み込み、Agent Skills、hooks、sub-issue 対応の GitHub MCP）と、Anthropic が公開しているエージェント設計の知見（context engineering、multi-agent、Claude Code best practices）に合わせて整理してある（[設計思想](#設計思想)）。

> **GitHub Copilot で使いたい場合**: 同じワークフローを Copilot の機構に移植した **Copilot 版テンプレート** は、v2.4.1 の時点で別のリポジトリ [issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot) に切り出した。このリポジトリは Claude Code 版だけを扱い、Copilot 版の改善は入れない。いま Copilot 版を使っているプロジェクトは、[docs/upgrade-notes.md](docs/upgrade-notes.md) の手順でテンプレート元を新しいリポジトリに切り替える。

## 特徴

- **Issue駆動開発**: すべての作業は GitHub Issue から始まる。1 Issue = 1 PR を徹底
- **Issue計画スキル** (`/issue-plan`): 要望や大きすぎる既存Issueを、規約で定めた粒度（1 Issue = 1 PR = `/issue-start` 1 セッション分）に分割し、依存順・DoD 付きで起票する。親子関係は GitHub の sub-issue で紐づける。粒度の基準は `.claude/rules/git-conventions.md` に明文化してあり、プロジェクトごとに調整できる
- **優先度スキル** (`/issue-priority`): Open Issue を「進行中」「人がいるセッション向け」に分け（無人実装を使うプロジェクトでは「ルーティン向け」も）、依存・後続・放置したときの損害から消化順と `priority:*` ラベル案を出す。ラベルはユーザー確認（Y/E/N）のあとに付ける。無人実装に任せてよい Issue の条件の正本も持つ
- **定期ルーティン（任意）**: Claude Code のクラウドのスケジュールタスク（research preview）で、日次のトリアージ（`daily-triage`）と週次の起票（`weekly`）を回せる。日次はメモ inbox と知見ボードから Issue を起票し、`priority:*` の無い Issue に優先度を付け、着手順のおすすめを実行ログ Issue に残す。週次はコードスキャンから起票し、priority の付け直しの案を出す。任意で、人が `routine-ok` を付けた Issue を 1 件ずつ無人で PR まで進める `weekday-issue-start` も使える（マージは人）。手順書は `.claude/routines/`、登録は使う人だけ（[docs/routines-guide.md](docs/routines-guide.md)）
- **8 Phase の開発スキル** (`/issue-start`): Issue分析から PR作成・知見記録までを段階的に実行。Phase ごとにファイル分割された progressive disclosure 設計で、必要な手順だけがコンテキストに載る。ユーザー確認は Phase 1 の不足確認・Phase 4 の設計承認・スコープ外問題の起票・Phase 8 の投稿に集約し、それ以外は自律的に進む
- **決定論的ガードレール (hooks)**: ブランチ作成コマンドのブランチ名と `git commit` の件名、Bash ツール自身のシェルに一致して落とす `pkill -f` を PreToolUse hook が **exit 2 でブロック** し、理由を Claude に返す。CLAUDE.md の文章は「お願い」でしかなく長いセッションでは守られなくなるため、機械判定できる規約は hook で強制する
- **着手できる Issue の一覧**: `.claude/scripts/issue-ready.sh` が Open Issue を「着手できる」「依存待ち」「親」に分け、それぞれが塞いでいる Issue を添えて出す（`--json` も出せる）。依存が閉じているかは機械判定できるので、エージェントに全 Issue の本文を読ませない。bash と `gh` だけで動く（[着手できる Issue の一覧](#着手できる-issue-の一覧)）
- **専門サブエージェント**: `code-explorer`（探索）/ `code-architect`（設計）/ `code-reviewer`（実装者とは別のコンテキストでのレビュー、信頼度80以上のみ報告）。起動数はタスクの複雑さに応じて 1〜3 個
- **検証してから完了**: Phase 5 で DoD を検証手段（テスト・コマンド・操作）に翻訳し、振る舞いを仕様化できるなら失敗するテストを先に書く。テスト・リントはコミット前と Phase 6 の冒頭で通す。既存テストの書き換えやテストだけ通す実装はしない
- **スコープ外問題の起票フロー**: 作業中に見つけた別バグ・改善余地はその場で直さず、ユーザー確認（Y/E/N）を挟んで sub-issue として起票。PR の肥大化を防ぐ。ワークフロー自体のテンプレート汎用の改善は、利用プロジェクトに起票せずテンプレート元への還元に回す（作業を塞ぐ不具合は例外）
- **ワークフロー改善の知見ボード**: セッションで得た「ワークフロー自体への気づき」を常時 Open の meta Issue に累積し、継続的に改善する
- **知見のテンプレートへの還元と更新チェック**: 知見のうち「別プロジェクトでも起きる」汎用のものは、プロジェクト固有情報を除いた上でこのリポジトリに Issue として還元する。テンプレート側の改善は Release（`vX.Y.Z`）で刻まれ、利用プロジェクトの SessionStart hook が版の差を検知して更新用 Issue の起票を提案する（[docs/upstream-feedback.md](docs/upstream-feedback.md)）
- **コンテキスト効率ルール**: 1M トークンの窓があっても無関係なトークンは精度を下げる（context rot）ことを前提に、just-in-time の局所読み・サブエージェントによる隔離・`/clear` での仕切り直しを規約化

## 前提

- [Claude Code](https://claude.com/claude-code)（CLI / デスクトップアプリ / IDE拡張 / web のいずれか）
- GitHub リポジトリ（Issue / PR を使うため）
- **bash**（Windows は Git Bash で可）と **`jq`**（無ければ `node` か `python3` のいずれか。hooks が JSON パースに使い、どれも無いと git のブランチ・コミット系と `pkill` / `pgrep` のコマンドが止まる）
- GitHub 操作手段:
  - [GitHub MCP サーバー](https://github.com/github/github-mcp-server)（推奨。`.mcp.json` に同梱済み。初回は `/mcp` で OAuth 認証する）
  - `gh` CLI（フォールバック。`.claude/scripts/` の `issue-ready.sh`・`knowledge-board.sh` は `gh` で動く）

## クイックスタート

### 1. テンプレートをプロジェクトにコピー

```bash
# このリポジトリを取得
git clone https://github.com/Sakuya398-Yamada/issue-driven-dev-starter.git

# 新規 or 既存プロジェクトのルートにコピー
cp -r issue-driven-dev-starter/template/. /path/to/your-project/
```

> 既存プロジェクトに `CLAUDE.md`・`.claude/`・`.github/`・`.mcp.json`・`.gitattributes` が既にある場合は、上書き前に差分を確認してマージすること。

### 2. プレースホルダーを埋める

コピーしたファイル内の `<...>` と `TODO` コメントを自分のプロジェクトに合わせて置き換える：

| ファイル | 置き換える内容 |
|---------|---------------|
| `CLAUDE.md` | プロジェクト名・概要 |
| `.claude/rules/tech-stack.md` | 技術スタック・開発環境・テストコマンド |
| `.claude/rules/coding-standards.md` | 言語・命名規約・ディレクトリ構成 |
| `.claude/agents/*.md` | 末尾の「Project Context」節（スタックと主要ディレクトリ、テストコマンド） |
| `.claude/rules/workflow-feedback.md` | 知見ボードIssue番号（手順5で作成後に記入） |
| `.claude/skills/issue-start/SKILL.md` | 知見ボードIssue番号・接続済みMCPサーバーの表 |

Claude Code に「`<...>` プレースホルダーと TODO コメントを探して、このプロジェクトに合わせて埋めるのを手伝って」と頼むのが早い。

`.claude/template-version`（テンプレート元リポジトリと取り込んだ版 `vX.Y.Z`）は同梱されているので記入不要。SessionStart hook がこの版と最新 Release を比較して更新を通知する。このリポジトリをフォークして独自テンプレートにする場合だけ `repo` を書き換える（[docs/upstream-feedback.md](docs/upstream-feedback.md)）。

### 3. `.gitignore` に追記

```
.claude/worktrees/
.claude/settings.local.json
```

`claude --worktree` が作る作業ツリーと、個人用の権限設定をコミットしないため。

### 4. GitHub ラベルを作成

```bash
gh label create feature --color 0E8A16 --description "新機能"
gh label create refactor --color F9D0C4 --description "リファクタリング"
gh label create meta --color 6B5B95 --description "ワークフロー改善の知見ボード等"
gh label create question --color D876E3 --description "要確認・議論"
gh label create "priority:high" --color B60205 --description "優先度高"
gh label create "priority:medium" --color FBCA04 --description "優先度中"
gh label create "priority:low" --color C2E0C6 --description "優先度低"
```

（`bug` と `docs`（`documentation`）は GitHub のデフォルトラベルを流用してもよい。`docs` 名で揃える場合は `gh label create docs --color 0075CA` を追加。）

無人実装のルーティン `weekday-issue-start`（任意。[docs/routines-guide.md](docs/routines-guide.md)「`weekday-issue-start` を使う場合」）を使うなら、次の 2 つも作る。`routine-ok` があると、`/issue-priority` と日次・週次のルーティンが「無人実装を使うプロジェクト」として扱うので、使わないなら作らない:

```bash
gh label create routine-ok --color C5DEF5 --description "人が無人実装を許可した印（付けるのは人だけ）"
gh label create needs-decision --color D4C5F9 --description "無人実行が判断できず、人の決定待ち"
```

### 5. 知見ボードIssueを作成

```bash
gh issue create --title "meta: ワークフロー改善の知見ボード" --label meta \
  --body "ワークフロー全体（/issue-start の手順、.claude/rules/*、CLAUDE.md、hooks、agents、skills、MCP 運用等）への気づきを累積する常時Open Issue。運用規約は .claude/rules/workflow-feedback.md 参照。"
```

（または GitHub の New issue 画面から **「知見ボード（meta）」テンプレート**（`.github/ISSUE_TEMPLATE/workflow-feedback.md`）で作成してもよい。）

発行された Issue 番号を以下の 2 箇所に記入する：

- `.claude/rules/workflow-feedback.md` の「Issue番号」
- `.claude/skills/issue-start/SKILL.md` の「知見ボードIssue」

### 6. コミットして動作確認

```bash
git add CLAUDE.md .claude/ .github/ .mcp.json .gitattributes .gitignore
git commit -m "chore: Issue駆動開発ワークフローを導入"
```

Claude Code を起動（または再起動）して確認：

1. **MCP**: `.mcp.json` の `github` サーバーの利用を承認し、`/mcp` で OAuth 認証する。`/mcp` 画面で `github` が connected になれば OK
2. **rules の読み込み**: `/context` で `.claude/rules/*.md` が読み込まれていることを確認する
3. **SessionStart hook**: セッション開始時に「Repository status」バナーが出る。「Template version」に `up to date`（またはオフライン時 `Latest: unknown`）が出ていれば更新チェックも動いている
4. **ブランチ名 hook**: Claude に `git checkout -b test-branch` を実行させると規約違反でブロックされる（`feature/#1-something` なら通る）
5. **コミット hook**: `git commit -m "test"` はブロック、`git commit -m "chore: 動作確認 #1"` は通る

> 注意: hooks は **Claude Code のツール呼び出しにのみ** 作用する。人間が直接ターミナルで打つ git コマンドは制約されない（人間の操作にも効かせたいなら、git hooks と CI を併用する。Copilot 版（[issue-driven-dev-starter-copilot](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter-copilot)）の git hooks と CI が流用できる）。

### 7. 最初の Issue で回してみる

1. GitHub 上で Issue を作成する。テンプレートに含まれる **「新規Issue」テンプレート**（`.github/ISSUE_TEMPLATE/issue.md`）を使うと、背景・目的 / 要件（やること・やらないこと） / 完了条件（DoD）が最初から揃う（規約の詳細は `.claude/rules/git-conventions.md` の「Issue」節）。Claude Code に分割・起票させるなら `/issue-plan <要望>` でもよい（粒度規約に沿った候補を提示し、Y/E/N 確認後に起票する）
2. Claude Code で:

   ```
   /issue-start #1
   ```

3. あとは Phase 1〜8 が順に進む。設計承認・スコープ外問題の起票・知見ボード追記など、要所でユーザー確認が入る

### 8. 定期ルーティンを登録する（任意）

日次のトリアージや週次の起票をクラウドのスケジュールタスクで回すなら、[docs/routines-guide.md](docs/routines-guide.md) の手順で、管理用の Issue（実行ログ・メモ inbox）を作って `.claude/rules/routines.md` に番号を書き、スケジュールタスクに登録する。使わないなら飛ばしてよい。

## ワークフローの全体像

```
ユーザー: 要望 → /issue-plan（任意: 粒度規約に沿って分割・起票） → Issue作成 → /issue-start #N
   │
   ▼
Phase 1  テンプレート更新チェック（更新があればセッションで一度だけ確認）
         Issue分析・不足確認・補完（ユーザーが決めることだけ質問して停止）
Phase 2  ラベル付与・ブランチ作成          ← hooks がブランチ名を強制
Phase 3  コード探索  （code-explorer ×1〜3、複雑さに応じて）※bug/docs はスキップ可
Phase 4  設計案の提示（code-architect ×1〜3）→ ユーザー承認 ※1 文で説明できる変更はスキップ可
         （手順書・規約から人の確認を外す変更は、1 文で説明できてもスキップしない）
Phase 5  検証手段の用意 → 実装 → テスト・リント → コミット  ← hooks がコミット規約を強制
Phase 6  テスト・リント通過 → コードレビュー（code-reviewer ×1〜3、信頼度80+のみ）
Phase 7  PR作成（closes #N 付き）
Phase 8  Issueへ実装メモ・ハマりどころを記録 ＋ 知見ボード追記
         ＋ テンプレート汎用の気づきをこのリポジトリへ Issue として還元
   │
   ▼
ユーザー: PR確認・マージ → Issue自動クローズ
```

横断ルール: スコープ外の問題を見つけたら**その場で直さず**、ユーザー確認を挟んで sub-issue として起票（Phase 1.5 の確認、Phase 3/5/6 の末尾）。

知見の還元と更新のループ（利用プロジェクト → このリポジトリ → Release → 利用プロジェクトの更新チェック）は [docs/upstream-feedback.md](docs/upstream-feedback.md) を参照。

## 着手できる Issue の一覧

次にどの Issue に着手できるかは、`.claude/scripts/issue-ready.sh` で出す。依存が閉じているかは機械判定できるので、エージェントに全 Issue の本文を読ませなくてよい。LLM は、優先度のように判断が要る所に使う。

```bash
bash .claude/scripts/issue-ready.sh                    # 人が読む一覧
bash .claude/scripts/issue-ready.sh --json             # 同じ内容を JSON で（別のツールから読むため）
bash .claude/scripts/issue-ready.sh --repo OWNER/REPO  # 既定は git の remote から gh が決める
```

```
## 着手できる (2)
- #10 feature: ユーザー設定画面を追加（塞いでいる: #11 #12）
- #13 bug: 日付計算が月末にずれる
## 依存待ち (2)
- #11 feature: 設定の保存 API を追加 ← #10
- #12 docs: 設定画面の使い方を書く ← #10
## 親（子の完了待ち） (1)
- #5 feature: 設定まわりを整える（sub-issue 1/3 完了）
## 注意 (1)
- #12: 本文だけにある依存: #10 / blocked by だけにある依存: なし
```

- 依存は、本文の「## 関連Issue」の `依存: #N` と、GitHub の依存関係（blocked by）の両方から読む（書き方は `.claude/skills/issue-start/dependencies.md`）。どちらか一方にあれば依存とみなし、依存先が 1 つでも Open なら依存待ちにする。本文は `依存:` で始まる行の、コロンの直後に続く `#N` の並び（`,`・`、`・空白区切り）だけを読む。文中で引用した「依存: #N」と、並びの後ろの注記（`依存: #10（#10 で足す節を触るため）`）の番号は数えない
- 着手できる Issue は、塞いでいる Issue の多い順に並ぶ。`meta` ラベルの Issue は出さず、sub-issue を持つ親 Issue は別枠に出す
- 「注意」には、本文と blocked by の食い違い、`not_planned` / `duplicate` で閉じた依存先、見つからない依存先を出す
- 要るのは bash と認証済みの `gh` だけ（JSON は `gh api --jq` で処理するので、jq は要らない）。REST だけを使うので、Claude Code のクラウドセッションでも動く。`bash` を付けて呼ぶのは、`/template-update` で取り込んだときなど、実行権限が付いていなくても動くようにするため
- `--json` の各 Issue には、`number` / `title` / `status`（`ready` / `blocked` / `parent`）/ `labels` / `blocked_by`（Open の依存先）/ `external_blocked_by`（別リポジトリの Open の依存先）/ `blocking`（この Issue が塞いでいる Issue）/ `body_only` / `relation_only`（片方にしか無い依存先）/ `sub_issues` / `notes` が入る

## ファイル構成

```
template/
├── CLAUDE.md                        # コア原則＋rules への索引
├── .mcp.json                        # GitHub MCP サーバー（プロジェクト共有設定）
├── .gitattributes                   # hooks の改行コードを LF に固定（Windows 対策）
├── .github/
│   └── ISSUE_TEMPLATE/              # Issueテンプレート（新規Issue / 知見ボード）
└── .claude/
    ├── settings.json                # 権限 allow/deny + hooks 登録
    ├── template-version             # テンプレート元リポジトリと取り込み済みの版（更新チェック用）
    ├── rules/                       # 起動時に自動で読み込まれる規約集
    │   ├── git-conventions.md       # ブランチ・コミット・PR・Issue・ラベル規約
    │   ├── coding-standards.md      # コーディング規約（要カスタマイズ）
    │   ├── tech-stack.md            # 技術スタック（要カスタマイズ）
    │   ├── context-efficiency.md    # コンテキスト効率・ファイル読解・サブエージェント委譲
    │   ├── workflow-feedback.md     # 知見ボード運用と、還元／更新取り込みの判定（手順は phases と /template-update）
    │   ├── routines.md              # 定期ルーティンの一覧・呼び出し文・事前に承認した書き込み（paths: で routines/ を触ったときだけ読む）
    │   └── documentation-policy.md  # CLAUDE.md と rules の書き分け方針
    ├── routines/
    │   ├── daily-triage.md          # 日次トリアージの手順書（スケジュールタスクに登録したときだけ動く）
    │   ├── weekly.md                # 週次の起票（コードスキャン）と priority の付け直し案の手順書
    │   └── weekday-issue-start.md   # 任意: routine-ok の Issue を 1 件、無人で PR まで進める手順書
    ├── hooks/
    │   ├── validate-branch-name.sh  # ブランチ名規約の強制（exit 2 でブロック）
    │   ├── validate-commit-message.sh # コミット規約の強制（exit 2 でブロック）
    │   ├── validate-pkill-pattern.sh # 自分のシェルに一致する pkill -f / pgrep -f を止める（exit 2）
    │   └── session-start-info.sh    # セッション開始時のリポジトリ状態バナー＋テンプレート更新チェック
    ├── scripts/
    │   ├── issue-ready.sh           # 着手できる Issue・依存待ちの Issue の一覧（--json も出せる）
    │   └── knowledge-board.sh       # 知見ボードのコメントを要る分だけ読み、回収済みの印を照合付きで付ける
    ├── agents/
    │   ├── code-explorer.md         # 探索エージェント（出力上限つき）
    │   ├── code-architect.md        # 設計エージェント（出力上限つき）
    │   └── code-reviewer.md         # レビューエージェント（信頼度80+のみ）
    └── skills/
        ├── issue-plan/
        │   └── SKILL.md             # /issue-plan 本体（要望 → 粒度規約に沿った Issue の分割・起票）
        ├── issue-priority/
        │   ├── SKILL.md             # /issue-priority 本体（Open Issue の順位表と priority ラベル案。付与はユーザー確認後）
        │   └── routine-candidates.md # 無人実装に任せてよい Issue の候補条件・選ぶ順・確かめ方（正本）
        ├── issue-start/
        │   ├── SKILL.md             # /issue-start 本体（Phase索引）
        │   ├── phases/01〜08        # 各Phaseの詳細手順
        │   ├── dependencies.md      # Issue の依存の付け方・読み方（本文の「依存: #N」と GitHub の blocked by）
        │   ├── pitfalls.md          # 環境依存のハマりどころ（条件 / 症状 / 回避 / 確認（版・年月・出自 Issue）。該当時だけ読む）
        │   └── pitfalls-cloud.md    # そのうち、条件が Claude Code のクラウドセッションのもの
        └── template-update/
            └── SKILL.md             # /template-update 本体（テンプレート更新の取り込み手順。更新用 Issue の Phase 5 で読む）
```

このリポジトリ自体には `tests/test-hooks.sh`（hooks の回帰テスト）、`tests/test-issue-ready.sh`・`tests/test-knowledge-board.sh`（`issue-ready.sh`・`knowledge-board.sh` を偽の `gh` で動かすテスト）、`tests/check-refs.py`（Markdown 内のパス参照が実在するか）、`tests/check-context-budget.py`（常駐コンテキスト = CLAUDE.md + `paths:` なし rules の合計が、テンプレート元自体の予算 400 行以下か。利用プロジェクト向けの目安 1000 行とは別。skill の各ファイルが 30,000 バイト未満かも見る）、`tests/check-frontmatter.py`（Markdown の frontmatter が厳密な YAML として読めるか）があり、CI（`.github/workflows/test-hooks.yml`）で実行される。hooks を変更したら `tests/test-hooks.sh` を、`issue-ready.sh` を変更したら `tests/test-issue-ready.sh` を、`knowledge-board.sh` を変更したら `tests/test-knowledge-board.sh` を、rules / CLAUDE.md / skills / docs を変更したら残る 3 つも手元で通すこと。予算を超えたら `refactor: rules 棚卸し` Issue を切って減らす（[docs/customization.md](docs/customization.md)「コンテキスト予算の点検」）。

## カスタマイズ

ブランチtype・コミットtypeの追加、Issue粒度の目安、Phaseの増減、hooksの緩和/強化、サブエージェントのモデル変更、コンテキスト予算の点検などは [docs/customization.md](docs/customization.md) を参照。

## テンプレートへの知見還元と更新

このテンプレートを使ったプロジェクトで得たワークフローの気づきは、`/issue-start` Phase 8 の最後に（ユーザー確認を挟んで）このリポジトリへ **`feedback` Issue** として還元される設計になっている（手動で起票する場合は Issue テンプレート「テンプレートへの知見還元」）。

テンプレート側の改善は **Release（`vX.Y.Z`）** で刻む。リリースは release-please が自動化しており、`main` への変更ごとに作られる Release PR をマージするだけでタグ・Release・テンプレート内の版番号が揃う。利用プロジェクトの SessionStart hook が `.claude/template-version` と最新 Release を比較し、差があれば `/issue-start` の冒頭で一度だけ「更新用 Issue を起票するか」を聞く。更新は独立した Issue / PR で行い、作業中の Issue には混ぜない。取り込みの手順は利用プロジェクト側の `/template-update` skill（`.claude/skills/template-update/SKILL.md`）にあり、更新用 Issue の Phase 5 で読まれる。

判定基準・抽象化ルール・リリース手順・取り込み手順は [docs/upstream-feedback.md](docs/upstream-feedback.md) を参照。

v1.x から v2.0.0 への更新は手作業を伴う。手順は [docs/migration-v2.md](docs/migration-v2.md)。版ごとの手動対応は [docs/upgrade-notes.md](docs/upgrade-notes.md) にまとめてある（`/template-update` もここを読む）。

## 設計思想

- **規約はAIへのお願いではなく hook で強制する**: CLAUDE.md の指示は助言であって保証ではなく、長いセッションや曖昧な状況では守られないことがある。ブランチ名・コミットメッセージのような機械判定できる規約は PreToolUse hook（exit 2）で決定論的にブロックし、文章には「なぜ」だけを残す
- **CLAUDE.md は索引に保つ**: 詳細規約は `.claude/rules/*.md` に分割する（Claude Code が自動で読み込む）。常時必要ではない手順は skill にして呼ばれたときだけ読ませ、言語固有の規約は `paths:` で該当ファイルを扱うときだけ読ませる。1 行ごとに「消すと Claude が間違えるか」を自問して肥大化を防ぐ
- **確認する場面を決めておく**: 仕様・設計の分岐のように「ユーザーが決めること」は決めた確認ポイント（不足確認・設計承認・スコープ外起票・GitHub 上の操作だけの Issue の適用・投稿）で聞き、調べれば分かることは自分で調べる。ツール呼び出し回数で質問を強制するような規則は探索を分断するだけなので置かない
- **検証手段を持たせる**: テスト・リント・動作確認で結果を確かめてから完了とする。レビューは実装したエージェントとは別の新しいコンテキストで行う（自分の書いたコードは自分では甘く見る）。レビュアーに「リンターが見つけること」を探させない
- **コンテキストは有限の注意予算として扱う**: 窓が 1M トークンあっても、無関係なトークンが増えるほど精度は落ちる。just-in-time で局所的に読み、横断調査はサブエージェントに隔離して要約だけ受け取り、Issue コメントを外部メモリにする。数値（500 行など）は目安であって機械的な上限ではない
- **サブエージェントはタスクの複雑さに合わせる**: 単純な変更は 1 個、観点が複数あるときだけ 2〜3 個。同じ観点を複数起動しても情報は増えず、トークンだけ増える
- **ワークフロー自体も Issue で改善する**: 知見ボード → 改善Issue昇格 → `/issue-start` で実装、のループでワークフローそのものを継続改善する
- **知見はテンプレートに還元し、改善は版で配る**: 利用プロジェクトで閉じさせず、テンプレート汎用の気づきはこのリポジトリの Issue に戻す。テンプレート側の改善は Release で刻み、利用側は hook が版の差を検知する。還元先は公開リポジトリなので、プロジェクト固有情報を除いた上で必ず人間が確認してから投稿する。更新も無人では行わない

参考にした一次情報：

- Anthropic, [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)（context rot、just-in-time 読込、サブエージェントによる隔離）
- Anthropic, [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)（サブエージェント数をタスクの複雑さに合わせる、委譲プロンプトに含める 4 要素）
- Anthropic, [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)（ワークフローの間に決定論的なゲートを置く、チェックポイントで人が判断する）
- Claude Code docs: [Best practices](https://code.claude.com/docs/en/best-practices)、[Memory（`.claude/rules/`）](https://code.claude.com/docs/en/memory)、[Hooks](https://code.claude.com/docs/en/hooks)、[Skills](https://code.claude.com/docs/en/skills)、[Subagents](https://code.claude.com/docs/en/sub-agents)
- Anthropic, [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)（強調語を減らし理由を書く、可逆な操作は進めて不可逆な操作だけ確認する）
- Chroma, [Context Rot](https://research.trychroma.com/context-rot)（入力長に伴う性能劣化の実測）

## ライセンス

MIT
