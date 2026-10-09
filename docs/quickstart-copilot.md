# クイックスタートガイド for GitHub Copilot

Claude Code 向けの Issue駆動開発ワークフロー（[README](../README.md)）を **GitHub Copilot** で使うためのガイド。テンプレートは `template-copilot/` に配置してある。

VS Code の Copilot Chat（エージェントモード）または Copilot CLI で `/issue-start #N` と入力すると、「Issue分析 → ブランチ作成 → 探索 → 設計（承認）→ 実装・検証 → レビュー → PR作成 → Issueへの記録」まで一気通貫で回せる。

## Claude Code 版との対応関係

Claude Code 固有の機構は、Copilot の対応機構に以下のようにマッピングしてある：

| Claude Code 版 | Copilot 版 | 備考 |
|---------------|-----------|------|
| `CLAUDE.md`（コア原則＋rules への索引） | `.github/copilot-instructions.md` | 全リクエストに自動適用される |
| `.claude/rules/*.md`（自動読み込みされる規約集） | `.github/instructions/*.instructions.md` | frontmatter の `applyTo` グロブで自動適用。`excludeAgent` で読者を絞れる |
| `.claude/skills/issue-start/`（8 Phase スキル、phases 分割） | `.github/skills/issue-start/`（同じ構成） | Agent Skills（オープン標準）。`/issue-start` で起動し、phases は必要になったときだけ読み込まれる。VS Code / Copilot CLI / cloud agent で使える |
| `.claude/skills/issue-plan/` | `.github/skills/issue-plan/` | `/issue-plan` で起動 |
| `.claude/agents/*.md`（サブエージェント） | `.github/agents/*.agent.md`（カスタムエージェント） | VS Code と Copilot CLI ではサブエージェントとして並列起動できる。cloud agent では使えないので同一セッションで逐次実行 |
| PreToolUse hooks（exit 2 でブロック） | `.github/hooks/validate-conventions.json` + 同じスクリプト（preToolUse、exit 2 で拒否）＋ `.githooks/`（git hooks）＋ CI | スクリプトは Claude 版と同一（参照する規約文書のパスだけ違う）。git hooks と CI は人間の操作と hooks が効かない環境のための多層防御 |
| `claude/*` セッションブランチの規約緩和 | `copilot/*`（cloud agent のブランチ）を同様に緩和 | 両方のテンプレートが両方の prefix を除外する |
| `.claude/rules/context-efficiency.md` | `.github/instructions/context-efficiency.instructions.md` | サブエージェント委譲の目安を含む |
| SessionStart hook（リポジトリ状態バナー・更新チェック） | なし（`/issue-start` Phase 1 手順 0.5 で `git ls-remote` により更新チェック） | Copilot にも `sessionStart` hook はあるが、出力がコンテキストに入る保証が無いので使っていない |
| `.mcp.json`（GitHub MCP） | Copilot CLI / cloud agent は GitHub MCP が組み込み。VS Code は `.vscode/mcp.json` に登録 | |

> ガードレールの仕組み・読み方・カスタマイズ方法は個別の解説ガイドを用意している：
> - git hooks（`.githooks/`）と preToolUse hook（`.github/hooks/`）→ [git-hooks-guide.md](git-hooks-guide.md)
> - CI（GitHub Actions / `validate-conventions.yml`）→ [github-actions-guide.md](github-actions-guide.md)

## 前提

- [GitHub Copilot](https://github.com/features/copilot) — 次のいずれか（併用可）:
  - VS Code + Copilot Chat のエージェントモード
  - [Copilot CLI](https://github.com/github/copilot-cli)（`npm install -g @github/copilot`。旧 `gh copilot` 拡張は廃止）
  - Copilot cloud agent（github.com で Issue を Copilot にアサインする。旧称 coding agent。有料プランで利用可）
- GitHub リポジトリ（Issue / PR / Actions を使うため）
- **bash** が動く環境（Windows は Git Bash で可）と **`jq`**（無ければ `node` か `python3`。preToolUse hook が JSON パースに使う）
- GitHub 操作手段のいずれか:
  - GitHub MCP サーバー（Copilot CLI / cloud agent は組み込み。VS Code は `.vscode/mcp.json` に `https://api.githubcopilot.com/mcp/` を登録）
  - `gh` CLI（フォールバック。sub-issue の `--parent` は 2.94 以降）

## クイックスタート

### 1. テンプレートをプロジェクトにコピー

```bash
# このリポジトリを取得
git clone https://github.com/Sakuya398-Yamada/issue-driven-dev-starter.git

# 新規 or 既存プロジェクトのルートにコピー
cp -r issue-driven-dev-starter/template-copilot/. /path/to/your-project/
```

> 既存プロジェクトに `.github/copilot-instructions.md`・`.github/workflows/`・`.gitattributes` が既にある場合は、上書き前に差分を確認してマージすること。`AGENTS.md` を既に使っているなら、`copilot-instructions.md` と内容を重複させない（両方読み込まれる）。

### 2. プレースホルダーを埋める

コピーしたファイル内の `<...>` と `TODO` コメントを自分のプロジェクトに合わせて置き換える：

| ファイル | 置き換える内容 |
|---------|---------------|
| `.github/copilot-instructions.md` | プロジェクト名・概要 |
| `.github/instructions/tech-stack.instructions.md` | 技術スタック・開発環境・テストコマンド |
| `.github/instructions/coding-standards.instructions.md` | 言語・命名規約・ディレクトリ構成 |
| `.github/agents/*.agent.md` | 末尾の「Project Context」節 |
| `.github/instructions/workflow-feedback.instructions.md` | 知見ボードIssue番号（手順5で作成後に記入） |
| `.github/skills/issue-start/SKILL.md` | 接続済み MCP サーバーの表 |

Copilot Chat に「`<...>` プレースホルダーと TODO コメントを探して、このプロジェクトに合わせて埋めるのを手伝って」と頼むのが早い。

`.github/template-version`（テンプレート元リポジトリと取り込んだ版 `vX.Y.Z`）は同梱されているので記入不要。`/issue-start` の Phase 1 でこの版と最新 Release を比較して更新を通知する。フォークして独自テンプレートにする場合だけ `repo` を書き換える（[upstream-feedback.md](upstream-feedback.md)）。

### 3. git hooks を有効化

```bash
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg .githooks/pre-push   # 実行権限が落ちている場合
```

> **重要**: `core.hooksPath` はリポジトリローカル設定なので、**クローンした各開発者が個別に実行する必要がある**。README やオンボーディング手順に含めておくとよい。preToolUse hook（`.github/hooks/`）はリポジトリに入れるだけで効き、cloud agent は **デフォルトブランチ** にある設定を読む。ローカル hooks が効かない環境は CI（`validate-conventions.yml`）が拾う。

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
  --body "ワークフロー全体（/issue-start の手順、.github/instructions/*、copilot-instructions.md、skills、agents、hooks、CI、MCP 運用等）への気づきを累積する常時Open Issue。運用規約は .github/instructions/workflow-feedback.instructions.md 参照。"
```

（または GitHub の New issue 画面から **「知見ボード（meta）」テンプレート**（`.github/ISSUE_TEMPLATE/workflow-feedback.md`）で作成してもよい。）

発行された Issue 番号を `.github/instructions/workflow-feedback.instructions.md` の「Issue番号」に記入する。

### 6. コミットして動作確認

```bash
git add .github/ .githooks/ .gitattributes
git commit -m "chore: Issue駆動開発ワークフローを導入"
```

動作確認：

1. **instructions の適用**: Copilot Chat で「このプロジェクトのブランチ命名規約は？」と聞くと `git-conventions.instructions.md` の内容が返る
2. **skills**: Copilot Chat（エージェントモード）または Copilot CLI で `/` を入力すると `issue-start` と `issue-plan` が候補に出る
3. **preToolUse hook**: エージェントに `git checkout -b test-branch` を実行させると拒否される（`feature/#1-something` なら通る）
4. **commit-msg hook**: `git commit -m "test"` はブロック、`git commit -m "chore: 動作確認 #1"` は通る
5. **pre-push hook**: `test-branch` のような名前のブランチは push でブロック、`feature/#1-something` は通る
6. **CI**: 適当なPRを作ると `validate-conventions` チェックが走る

> git hooks は Claude 版の PreToolUse hook と異なり **人間のコミット・push も等しく検証する**。緊急時の `--no-verify` は規約上バイパス禁止としているが、機械的には可能なので CI を最終防衛線とする。

### 7. 最初の Issue で回してみる

1. GitHub 上で Issue を作成する。テンプレートに含まれる **「新規Issue」テンプレート**（`.github/ISSUE_TEMPLATE/issue.md`）を使うと、背景・目的 / 要件（やること・やらないこと） / 完了条件（DoD）が最初から揃う（規約の詳細は `git-conventions.instructions.md` の「Issue」節）。Copilot に分割・起票させるなら `/issue-plan <要望>` でもよい
2. VS Code の Copilot Chat を**エージェントモード**に切り替えて（または Copilot CLI で）:

   ```
   /issue-start #1
   ```

3. あとは Phase 1〜8 が順に進む。設計承認・スコープ外問題の起票・知見ボード追記など、要所でユーザー確認が入る

## Copilot cloud agent で使う場合

github.com 上で Issue を Copilot にアサインする使い方（cloud agent、旧 coding agent）でも、このテンプレートはそのまま効く：

- cloud agent は `.github/copilot-instructions.md`・`.github/instructions/*.instructions.md`・`.github/skills/`・`.github/agents/`・`.github/hooks/`（いずれもデフォルトブランチ）を読み込み、規約（1 Issue = 1 PR、コミットメッセージ、PR本文フォーマット等）に従う
- ブランチ作成・PR作成は cloud agent が自動で行う。ブランチ名は `copilot/*` になるため、ブランチ名規約・コミットの Issue 番号必須は**免除**される（`claude/*` と同じ扱い）。PR は draft で作られる
- preToolUse hook（`.github/hooks/`）は cloud agent のツール呼び出しにも効く。ローカル git hooks は効かないが、CI（`validate-conventions.yml`）がPR上で規約を検証する
- 依存関係のインストールが要るなら `.github/workflows/copilot-setup-steps.yml` に書く。MCP サーバーの追加はリポジトリの Settings → Copilot → MCP servers（GitHub MCP と Playwright は既定で有効）
- サブエージェントと対話的な確認（設計承認・スコープ外起票の Y/E/N 等）は cloud agent では使えない。skill は設計案と前提を PR 本文に書く形にフォールバックする。**要所で人間が判断するフローを重視するなら、VS Code のエージェントモードか Copilot CLI で `/issue-start` を使う**こと

## ワークフローの全体像

```
ユーザー: 要望 → /issue-plan（任意: 粒度規約に沿って分割・起票） → Issue作成 → /issue-start #N
   │
   ▼
Phase 1  テンプレート更新チェック（更新があればセッションで一度だけ確認）
         Issue分析・不足確認・補完（ユーザーが決めることだけ質問して停止）
Phase 2  ラベル付与・ブランチ作成          ← preToolUse hook がブランチ名を検証
Phase 3  コード探索（code-explorer ×1〜3、複雑さに応じて）※bug/docs はスキップ可
Phase 4  設計案の提示（code-architect ×1〜3）→ ユーザー承認 ※1 文で説明できる変更はスキップ可
Phase 5  検証手段の用意 → 実装 → テスト・リント → コミット  ← preToolUse + commit-msg hook が規約を強制
Phase 6  テスト・リント通過 → コードレビュー（code-reviewer ×1〜3、信頼度80+のみ）
Phase 7  PR作成（closes #N 付き）          ← pre-push hook + CI が規約を強制
Phase 8  Issueへ実装メモ・ハマりどころを記録 ＋ 知見ボード追記
         ＋ テンプレート汎用の気づきをスターターキットへ Issue として還元
   │
   ▼
ユーザー: PR確認・マージ → Issue自動クローズ
```

横断ルール: スコープ外の問題を見つけたら**その場で直さず**、ユーザー確認を挟んで sub-issue として起票（Phase 3/5/6 末尾）。

## ファイル構成

```
template-copilot/
├── .gitattributes                        # hooks の改行コードを LF に固定（Windows 対策）
├── .githooks/
│   ├── commit-msg                        # コミット規約の強制（ローカル git hook）
│   └── pre-push                          # ブランチ名規約の強制（ローカル git hook）
└── .github/
    ├── copilot-instructions.md           # コア原則＋instructions への索引（全リクエストに自動適用）
    ├── template-version                  # テンプレート元リポジトリと取り込み済みの版（更新チェック用）
    ├── ISSUE_TEMPLATE/                   # Issueテンプレート（新規Issue / 知見ボード）
    ├── instructions/
    │   ├── git-conventions.instructions.md       # ブランチ・コミット・PR・Issue・ラベル規約
    │   ├── coding-standards.instructions.md      # コーディング規約（要カスタマイズ）
    │   ├── tech-stack.instructions.md            # 技術スタック（要カスタマイズ）
    │   ├── context-efficiency.instructions.md    # コンテキスト効率・サブエージェント委譲
    │   ├── workflow-feedback.instructions.md     # 知見ボード運用規約＋テンプレート元への還元／更新取り込み規約
    │   └── documentation-policy.instructions.md  # instructions / skills / agents / hooks の書き分け方針
    ├── skills/
    │   ├── issue-plan/
    │   │   └── SKILL.md                  # /issue-plan 本体
    │   └── issue-start/
    │       ├── SKILL.md                  # /issue-start 本体（Phase索引）
    │       └── phases/01〜08             # 各Phaseの詳細手順
    ├── agents/
    │   ├── code-explorer.agent.md        # 探索エージェント（出力上限つき）
    │   ├── code-architect.agent.md       # 設計エージェント（出力上限つき）
    │   └── code-reviewer.agent.md        # レビューエージェント（信頼度80+のみ）
    ├── hooks/
    │   ├── validate-conventions.json     # preToolUse hook の登録
    │   ├── validate-branch-name.sh       # ブランチ名規約の強制（Claude 版と同一スクリプト）
    │   └── validate-commit-message.sh    # コミット規約の強制（Claude 版と同一スクリプト）
    └── workflows/
        └── validate-conventions.yml      # ブランチ名・コミット規約のCI検証
```

## テンプレートへの知見還元と更新

Claude 版と同様に、`/issue-start` Phase 8 の最後で **テンプレート汎用** と判定された気づきは、ユーザー確認を挟んでスターターキットに `feedback` Issue として還元される（GitHub MCP の `issue_write`、または `gh issue create -R Sakuya398-Yamada/issue-driven-dev-starter --label feedback`）。

更新チェックは `/issue-start` Phase 1 手順 0.5 で `git ls-remote --tags` を打って `.github/template-version` と比較する。差があればセッションで一度だけ「更新用 Issue を起票するか」を聞き、更新は独立した Issue / PR で行う。

判定基準・抽象化ルール（公開リポジトリなのでプロジェクト固有情報を書かない）・取り込み手順は [upstream-feedback.md](upstream-feedback.md) を参照。

## カスタマイズ

基本的な考え方は [customization.md](customization.md)（Claude 版）と同じ。Copilot 版でファイルの対応先が変わる点だけ挙げる：

### ブランチtype / コミットtype を増減する

規約は 5 箇所で同期している。変更時は必ず全部を揃えること（このリポジトリの `tests/test-hooks.sh` が同期を検査する）：

| 箇所 | 何を変える |
|------|-----------|
| `.github/instructions/git-conventions.instructions.md` | 規約の文書（type表・例） |
| `.github/hooks/validate-branch-name.sh` | `convention_re='^(feature|fix|refactor|docs)/#[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'` |
| `.github/hooks/validate-commit-message.sh` | `type_re='^(feat|fix|refactor|test|docs|chore|style)(\([^)]+\))?!?: [^[:space:]]'` |
| `.githooks/pre-push` / `.githooks/commit-msg` | 上記と同じ正規表現 |
| `.github/workflows/validate-conventions.yml` | 上記と同じ正規表現（branch-name / commit-messages 両ジョブ） |

### Issue番号必須を緩和する

- ブランチ名の Issue 番号を任意にしたい → `validate-branch-name.sh`・`pre-push`・CI の正規表現から `#[0-9]+-` を外す
- コミットの Issue 番号必須を外したい → `validate-commit-message.sh`・`commit-msg`・CI の `issue_optional` 判定を常に 1 にする

### Phase を増減する

`.github/skills/issue-start/phases/` のファイル単位で足し引きし、`SKILL.md` の「Phase一覧」表を更新する（Claude 版と同じ構成）。

### サブエージェントの調整

`.github/agents/*.agent.md` の frontmatter で `tools`（`read` / `search` / `execute` / `edit` / `agent` / `web`）と `model` を変えられる。「Output Budget」節で返却量を調整する。cloud agent でも使うエージェントには `target` を指定しない（既定で両環境）。

### Issue の粒度を調整する／`/issue-plan` を使わない

粒度の目安は `git-conventions.instructions.md` の「粒度」表を書き換える（`/issue-plan` と `/issue-start` Phase 1 の粒度チェックは同じ表を参照する）。`/issue-plan` を使わない場合は `.github/skills/issue-plan/` を削除し、`copilot-instructions.md` の「開発フロー」と `git-conventions.instructions.md` の `/issue-plan` への言及を消す。粒度の表自体は Phase 1 のチェックで使うので残しておく。

### 対象ファイルを絞った規約を追加する

`.github/instructions/` に新しい `*.instructions.md` を追加し、frontmatter の `applyTo` にグロブを書く（例: `applyTo: "src/api/**/*.ts"`）。code review にだけ読ませたくないなら `excludeAgent: "code-review"`。追加したら `copilot-instructions.md` の索引テーブルにも 1 行足す。

### hooks を足す

`.github/hooks/validate-conventions.json` の `preToolUse` 配列にエントリを足す（`matcher` はツール名の正規表現。`bash` / `edit` / `create` 等）。`postToolUse` や `sessionStart` も同じファイルに書ける。スクリプトは stdin の JSON を読み、拒否するときは `{"permissionDecision":"deny","permissionDecisionReason":"..."}` を出力して exit 2 する。
