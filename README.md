# Issue駆動開発スターターキット for Claude Code

GitHub Issue を唯一の情報源として Claude Code に開発を進めさせる **Issue駆動開発ワークフロー** のテンプレート集。
`/issue-start #N` の一言で「Issue分析 → ブランチ作成 → 探索 → 設計 → 実装 → レビュー → PR作成 → Issueへの記録」まで一気通貫で回せる。

実プロジェクト Issue を回して育てたワークフローを、任意のプロジェクトで使えるように汎用化したもの。

## 特徴

- **Issue駆動開発**: すべての作業は GitHub Issue から始まる。1 Issue = 1 PR を徹底
- **8 Phase の開発スキル** (`/issue-start`): Issue分析から PR作成・知見記録までを段階的に実行。Phase ごとにファイル分割された progressive disclosure 設計で、コンテキストを無駄にしない
- **決定論的ガードレール (hooks)**: ブランチ名・コミットメッセージの規約違反を PreToolUse hook が **exit 2 でブロック**。「AIへのお願い」ではなく機械的に強制する
- **専門サブエージェント**: `code-explorer`（探索）/ `code-architect`（設計）/ `code-reviewer`（レビュー、信頼度80以上のみ報告）を並列起動して観点を分散
- **スコープ外問題の起票フロー**: 作業中に見つけた別バグ・改善余地はその場で直さず、ユーザー確認（Y/E/N）を挟んで子Issue化。PR の肥大化を防ぐ
- **ワークフロー改善の知見ボード**: セッションで得た「ワークフロー自体への気づき」を常時Openの meta Issue に累積し、継続的に改善する
- **コンテキスト効率ルール**: 大きいファイルの全読み禁止・サブエージェント委譲時の返却量上限指定など、Stream タイムアウトを避ける運用ルール込み

## 前提

- [Claude Code](https://claude.com/claude-code)（CLI / デスクトップアプリ / IDE拡張のいずれか）
- GitHub リポジトリ（Issue / PR を使うため）
- **Node.js**（hooks が JSON パースに `node` を使用）と **bash**（Windows は Git Bash で可。hooks は Windows 11 + Git Bash で動作実績あり）
- GitHub 操作手段のいずれか:
  - [GitHub MCP サーバー](https://github.com/github/github-mcp-server)（推奨。`.mcp.json` に登録）
  - `gh` CLI（フォールバック）

## クイックスタート

### 1. テンプレートをプロジェクトにコピー

```bash
# このリポジトリを取得
git clone https://github.com/Sakuya398-Yamada/issue-driven-dev-starter.git

# 新規 or 既存プロジェクトのルートにコピー
cp -r issue-driven-dev-starter/template/. /path/to/your-project/
```

> 既存プロジェクトに `CLAUDE.md` や `.claude/` が既にある場合は、上書き前に差分を確認してマージすること。

### 2. プレースホルダーを埋める

コピーしたファイル内の `<...>` と `TODO` コメントを自分のプロジェクトに合わせて置き換える：

| ファイル | 置き換える内容 |
|---------|---------------|
| `CLAUDE.md` | プロジェクト名・概要 |
| `.claude/rules/tech-stack.md` | 技術スタック・開発環境・コマンド |
| `.claude/rules/coding-standards.md` | 言語・命名規約・ディレクトリ構成 |
| `.claude/agents/*.md` | 末尾の「Project Context」節（スタックと主要ディレクトリ） |
| `.claude/rules/workflow-feedback.md` | 知見ボードIssue番号（手順4で作成後に記入） |
| `.claude/skills/issue-start/SKILL.md` | 知見ボードIssue番号・接続済みMCPサーバーの表 |

Claude Code に「`<...>` プレースホルダーと TODO コメントを探して、このプロジェクトに合わせて埋めるのを手伝って」と頼むのが早い。

### 3. GitHub ラベルを作成

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

### 4. 知見ボードIssueを作成

```bash
gh issue create --title "meta: ワークフロー改善の知見ボード" --label meta \
  --body "ワークフロー全体（/issue-start の手順、.claude/rules/*、CLAUDE.md、hooks、skills、MCP 運用等）への気づきを累積する常時Open Issue。運用規約は .claude/rules/workflow-feedback.md 参照。"
```

発行された Issue 番号を以下の 2 箇所に記入する：

- `.claude/rules/workflow-feedback.md` の「Issue番号」
- `.claude/skills/issue-start/SKILL.md` の「知見ボードIssue」

### 5. コミットして動作確認

```bash
git add CLAUDE.md .claude/
git commit -m "chore: Issue駆動開発ワークフローを導入"
```

Claude Code を起動（または再起動）して確認：

1. **SessionStart hook**: セッション開始時に「Repository status」バナーが出る
2. **ブランチ名 hook**: Claude に `git checkout -b test-branch` を実行させると規約違反でブロックされる（`feature/#1-something` なら通る）
3. **コミット hook**: `git commit -m "test"` はブロック、`git commit -m "chore: 動作確認 #1"` は通る

> 注意: hooks は **Claude Code のツール呼び出しにのみ** 作用する。人間が直接ターミナルで打つ git コマンドは制約されない。

### 6. 最初の Issue で回してみる

1. GitHub 上で Issue を作成（背景・目的 / 要件 / 完了条件（DoD）を書く。詳細は `.claude/rules/git-conventions.md` の「Issue」節）
2. Claude Code で:

   ```
   /issue-start #1
   ```

3. あとは Phase 1〜8 が順に進む。設計承認・スコープ外問題の起票・知見ボード追記など、要所でユーザー確認が入る

## ワークフローの全体像

```
ユーザー: Issue作成 → /issue-start #N
   │
   ▼
Phase 1  Issue分析・不足確認・自動補完（不足があれば質問して停止）
Phase 2  ラベル付与・ブランチ作成          ← hooks がブランチ名を強制
Phase 3  コード探索  （code-explorer ×2〜3 並列）※bug/docs はスキップ可
Phase 4  設計案の比較（code-architect ×2〜3 並列）→ ユーザー承認
Phase 5  実装・コミット                    ← hooks がコミット規約を強制
Phase 6  コードレビュー（code-reviewer ×3 並列、信頼度80+のみ）
Phase 7  PR作成（closes #N 付き）
Phase 8  Issueへ実装メモ・ハマりどころを記録 ＋ 知見ボード追記
   │
   ▼
ユーザー: PR確認・マージ → Issue自動クローズ
```

横断ルール: スコープ外の問題を見つけたら**その場で直さず**、ユーザー確認を挟んで子Issueとして起票（Phase 3/5/6 末尾）。

## ファイル構成

```
template/
├── CLAUDE.md                        # コア原則＋rules への索引（Memory Imports）
└── .claude/
    ├── settings.json                # 権限 allow/deny + hooks 登録
    ├── rules/
    │   ├── git-conventions.md       # ブランチ・コミット・PR・Issue・ラベル規約
    │   ├── coding-standards.md      # コーディング規約（要カスタマイズ）
    │   ├── tech-stack.md            # 技術スタック（要カスタマイズ）
    │   ├── context-efficiency.md    # コンテキスト効率・ファイル読解ルール
    │   ├── workflow-feedback.md     # 知見ボード運用規約
    │   └── documentation-policy.md  # CLAUDE.md と rules の書き分け方針
    ├── hooks/
    │   ├── validate-branch-name.sh  # ブランチ名規約の強制（exit 2 でブロック）
    │   ├── validate-commit-message.sh # コミット規約の強制（exit 2 でブロック）
    │   └── session-start-info.sh    # セッション開始時のリポジトリ状態バナー
    ├── agents/
    │   ├── code-explorer.md         # 探索エージェント（出力上限つき）
    │   ├── code-architect.md        # 設計エージェント（出力上限つき）
    │   └── code-reviewer.md         # レビューエージェント（信頼度80+のみ）
    └── skills/
        └── issue-start/
            ├── SKILL.md             # /issue-start 本体（Phase索引）
            └── phases/01〜08        # 各Phaseの詳細手順
```

## カスタマイズ

ブランチtype・コミットtypeの追加、Phaseの増減、hooksの緩和/強化などは [docs/customization.md](docs/customization.md) を参照。

## 設計思想

- **規約はAIへのお願いではなく hook で強制する**: LLM は長いセッションで指示を忘れる。ブランチ名・コミットメッセージのような機械判定できる規約は PreToolUse hook（exit 2）で決定論的にブロックする
- **CLAUDE.md は索引に保つ**: 詳細規約は `.claude/rules/*.md` に分割し `@import` する。コンテキストの肥大化と規約の陳腐化を防ぐ
- **要所で必ず人間が判断する**: 設計承認・スコープ外問題の起票・知見ボード書き込みは無人化しない（Y/E/N 確認を挟む）
- **ワークフロー自体も Issue で改善する**: 知見ボード → 改善Issue昇格 → `/issue-start` で実装、のループでワークフローそのものを継続改善する

## ライセンス

MIT
