# Issue駆動開発スターターキット for Claude Code

GitHub Issue を唯一の情報源として Claude Code に開発を進めさせる **Issue駆動開発ワークフロー** のテンプレート集。
`/issue-start #N` の一言で「Issue分析 → ブランチ作成 → 探索 → 設計（承認）→ 実装・検証 → レビュー → PR作成 → Issueへの記録」まで一気通貫で回せる。その入口となる Issue の分割・起票も `/issue-plan` で同じ粒度規約に沿って行える。

実プロジェクトで Issue を回して育てたワークフローを、任意のプロジェクトで使えるように汎用化したもの。Claude Code の現行仕様（`.claude/rules/` の自動読み込み、Agent Skills、hooks、sub-issue 対応の GitHub MCP）と、Anthropic が公開しているエージェント設計の知見（context engineering、multi-agent、Claude Code best practices）に合わせて整理してある（[設計思想](#設計思想)）。

> **GitHub Copilot で使いたい場合**: 同じワークフローを Copilot の機構（`copilot-instructions.md` / `.github/instructions/` / `.github/skills/` / `.github/agents/` / `.github/hooks/` + git hooks + CI）に移植した **Copilot 版テンプレート** を `template-copilot/` に用意している。セットアップ手順と Claude 版との対応関係は [docs/quickstart-copilot.md](docs/quickstart-copilot.md) を参照。以下このREADMEは Claude Code 版の説明。

## 特徴

- **Issue駆動開発**: すべての作業は GitHub Issue から始まる。1 Issue = 1 PR を徹底
- **Issue計画スキル** (`/issue-plan`): 要望や大きすぎる既存Issueを、規約で定めた粒度（1 Issue = 1 PR = `/issue-start` 1 セッション分）に分割し、依存順・DoD 付きで起票する。親子関係は GitHub の sub-issue で紐づける。粒度の基準は `.claude/rules/git-conventions.md` に明文化してあり、プロジェクトごとに調整できる
- **8 Phase の開発スキル** (`/issue-start`): Issue分析から PR作成・知見記録までを段階的に実行。Phase ごとにファイル分割された progressive disclosure 設計で、必要な手順だけがコンテキストに載る。ユーザー確認は Phase 1 の不足確認・Phase 4 の設計承認・スコープ外問題の起票・Phase 8 の投稿に集約し、それ以外は自律的に進む
- **決定論的ガードレール (hooks)**: ブランチ作成コマンドのブランチ名と `git commit` の件名を PreToolUse hook が **exit 2 でブロック** し、理由を Claude に返す。CLAUDE.md の文章は「お願い」でしかなく長いセッションでは守られなくなるため、機械判定できる規約は hook で強制する
- **専門サブエージェント**: `code-explorer`（探索）/ `code-architect`（設計）/ `code-reviewer`（実装者とは別のコンテキストでのレビュー、信頼度80以上のみ報告）。起動数はタスクの複雑さに応じて 1〜3 個
- **検証してから完了**: Phase 5 で DoD を検証手段（テスト・コマンド・操作）に翻訳し、振る舞いを仕様化できるなら失敗するテストを先に書く。テスト・リントはコミット前と Phase 6 の冒頭で通す。既存テストの書き換えやテストだけ通す実装はしない
- **スコープ外問題の起票フロー**: 作業中に見つけた別バグ・改善余地はその場で直さず、ユーザー確認（Y/E/N）を挟んで sub-issue として起票。PR の肥大化を防ぐ
- **ワークフロー改善の知見ボード**: セッションで得た「ワークフロー自体への気づき」を常時 Open の meta Issue に累積し、継続的に改善する
- **知見のテンプレートへの還元と更新チェック**: 知見のうち「別プロジェクトでも起きる」汎用のものは、プロジェクト固有情報を除いた上でこのリポジトリに Issue として還元する。テンプレート側の改善は Release（`vX.Y.Z`）で刻まれ、利用プロジェクトの SessionStart hook が版の差を検知して更新用 Issue の起票を提案する（[docs/upstream-feedback.md](docs/upstream-feedback.md)）
- **コンテキスト効率ルール**: 1M トークンの窓があっても無関係なトークンは精度を下げる（context rot）ことを前提に、just-in-time の局所読み・サブエージェントによる隔離・`/clear` での仕切り直しを規約化

## 前提

- [Claude Code](https://claude.com/claude-code)（CLI / デスクトップアプリ / IDE拡張 / web のいずれか）
- GitHub リポジトリ（Issue / PR を使うため）
- **bash**（Windows は Git Bash で可）と **`jq`**（無ければ `node` か `python3` のいずれか。hooks が JSON パースに使う）
- GitHub 操作手段:
  - [GitHub MCP サーバー](https://github.com/github/github-mcp-server)（推奨。`.mcp.json` に同梱済み。初回は `/mcp` で OAuth 認証する）
  - `gh` CLI（フォールバック）

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

> 注意: hooks は **Claude Code のツール呼び出しにのみ** 作用する。人間が直接ターミナルで打つ git コマンドは制約されない（人間の操作にも効かせたいなら Copilot 版の git hooks + CI を併用する）。

### 7. 最初の Issue で回してみる

1. GitHub 上で Issue を作成する。テンプレートに含まれる **「新規Issue」テンプレート**（`.github/ISSUE_TEMPLATE/issue.md`）を使うと、背景・目的 / 要件（やること・やらないこと） / 完了条件（DoD）が最初から揃う（規約の詳細は `.claude/rules/git-conventions.md` の「Issue」節）。Claude Code に分割・起票させるなら `/issue-plan <要望>` でもよい（粒度規約に沿った候補を提示し、Y/E/N 確認後に起票する）
2. Claude Code で:

   ```
   /issue-start #1
   ```

3. あとは Phase 1〜8 が順に進む。設計承認・スコープ外問題の起票・知見ボード追記など、要所でユーザー確認が入る

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
Phase 5  検証手段の用意 → 実装 → テスト・リント → コミット  ← hooks がコミット規約を強制
Phase 6  テスト・リント通過 → コードレビュー（code-reviewer ×1〜3、信頼度80+のみ）
Phase 7  PR作成（closes #N 付き）
Phase 8  Issueへ実装メモ・ハマりどころを記録 ＋ 知見ボード追記
         ＋ テンプレート汎用の気づきをこのリポジトリへ Issue として還元
   │
   ▼
ユーザー: PR確認・マージ → Issue自動クローズ
```

横断ルール: スコープ外の問題を見つけたら**その場で直さず**、ユーザー確認を挟んで sub-issue として起票（Phase 3/5/6 末尾）。

知見の還元と更新のループ（利用プロジェクト → このリポジトリ → Release → 利用プロジェクトの更新チェック）は [docs/upstream-feedback.md](docs/upstream-feedback.md) を参照。

## ファイル構成

Copilot 版は `template-copilot/`（構成は [docs/quickstart-copilot.md](docs/quickstart-copilot.md) 参照）。

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
    │   ├── workflow-feedback.md     # 知見ボード運用規約＋テンプレート元への還元／更新取り込み規約
    │   └── documentation-policy.md  # CLAUDE.md と rules の書き分け方針
    ├── hooks/
    │   ├── validate-branch-name.sh  # ブランチ名規約の強制（exit 2 でブロック）
    │   ├── validate-commit-message.sh # コミット規約の強制（exit 2 でブロック）
    │   └── session-start-info.sh    # セッション開始時のリポジトリ状態バナー＋テンプレート更新チェック
    ├── agents/
    │   ├── code-explorer.md         # 探索エージェント（出力上限つき）
    │   ├── code-architect.md        # 設計エージェント（出力上限つき）
    │   └── code-reviewer.md         # レビューエージェント（信頼度80+のみ）
    └── skills/
        ├── issue-plan/
        │   └── SKILL.md             # /issue-plan 本体（要望 → 粒度規約に沿った Issue の分割・起票）
        └── issue-start/
            ├── SKILL.md             # /issue-start 本体（Phase索引）
            └── phases/01〜08        # 各Phaseの詳細手順
```

このリポジトリ自体には `tests/test-hooks.sh`（両テンプレートの hooks の回帰テストと正規表現の同期チェック）があり、CI（`.github/workflows/test-hooks.yml`）で実行される。hooks を変更したら `tests/test-hooks.sh` を通すこと。

## カスタマイズ

ブランチtype・コミットtypeの追加、Issue粒度の目安、Phaseの増減、hooksの緩和/強化、サブエージェントのモデル変更などは [docs/customization.md](docs/customization.md) を参照。

## テンプレートへの知見還元と更新

このテンプレートを使ったプロジェクトで得たワークフローの気づきは、`/issue-start` Phase 8 の最後に（ユーザー確認を挟んで）このリポジトリへ **`feedback` Issue** として還元される設計になっている（手動で起票する場合は Issue テンプレート「テンプレートへの知見還元」）。

テンプレート側の改善は **Release（`vX.Y.Z`）** で刻む。リリースは release-please が自動化しており、`main` への変更ごとに作られる Release PR をマージするだけでタグ・Release・テンプレート内の版番号が揃う。利用プロジェクトの SessionStart hook が `.claude/template-version` と最新 Release を比較し、差があれば `/issue-start` の冒頭で一度だけ「更新用 Issue を起票するか」を聞く。更新は独立した Issue / PR で行い、作業中の Issue には混ぜない。

判定基準・抽象化ルール・リリース手順・取り込み手順は [docs/upstream-feedback.md](docs/upstream-feedback.md) を参照。

## 設計思想

- **規約はAIへのお願いではなく hook で強制する**: CLAUDE.md の指示は助言であって保証ではなく、長いセッションや曖昧な状況では守られないことがある。ブランチ名・コミットメッセージのような機械判定できる規約は PreToolUse hook（exit 2）で決定論的にブロックし、文章には「なぜ」だけを残す
- **CLAUDE.md は索引に保つ**: 詳細規約は `.claude/rules/*.md` に分割する（Claude Code が自動で読み込む）。常時必要ではない手順は skill にして呼ばれたときだけ読ませ、言語固有の規約は `paths:` で該当ファイルを扱うときだけ読ませる。1 行ごとに「消すと Claude が間違えるか」を自問して肥大化を防ぐ
- **確認する場面を決めておく**: 仕様・設計の分岐のように「ユーザーが決めること」は決めた確認ポイント（不足確認・設計承認・スコープ外起票・投稿）で聞き、調べれば分かることは自分で調べる。ツール呼び出し回数で質問を強制するような規則は探索を分断するだけなので置かない
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
