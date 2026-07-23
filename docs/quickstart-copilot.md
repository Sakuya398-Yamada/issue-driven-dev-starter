# クイックスタートガイド for GitHub Copilot

Claude Code 向けの Issue駆動開発ワークフロー（[README](../README.md)）を **GitHub Copilot** で使うためのガイド。テンプレートは `template-copilot/` に配置してある。

VS Code の Copilot Chat（エージェントモード）で `/issue-start #N` と入力すると、「Issue分析 → ブランチ作成 → 探索 → 設計 → 実装 → セルフレビュー → PR作成 → Issueへの記録」まで一気通貫で回せる。

## Claude Code 版との対応関係

Claude Code 固有の機構は、Copilot の対応機構に以下のようにマッピングしてある：

| Claude Code 版 | Copilot 版 | 備考 |
|---------------|-----------|------|
| `CLAUDE.md`（コア原則＋Memory Imports） | `.github/copilot-instructions.md` | 全リクエストに自動適用される |
| `.claude/rules/*.md`（`@import` される規約集） | `.github/instructions/*.instructions.md` | frontmatter の `applyTo` グロブで自動適用 |
| `.claude/skills/issue-start/`（8 Phase スキル） | `.github/prompts/issue-start.prompt.md` | VS Code で `/issue-start` として起動。Copilot は Phase ファイルの逐次読み込み（progressive disclosure）ができないため 1 ファイルに凝縮 |
| PreToolUse hooks（exit 2 でブロック） | `.githooks/`（git hooks）＋ CI | Copilot にツール実行前フックは無いため、`commit-msg` / `pre-push` の git hooks と PR 上の CI（`validate-conventions.yml`）の二段構えで強制 |
| サブエージェント（code-explorer / architect / reviewer の並列起動） | 同一セッション内で観点を切り替えて逐次実行 | Copilot に並列サブエージェント機構は無い。Phase 3/4/6 は「3観点で順番に」実行する形に変更 |
| `claude/*` セッションブランチの規約緩和 | `copilot/*`（Copilot coding agent のブランチ）を同様に緩和 | |
| `.claude/rules/context-efficiency.md` | なし | Claude Code の Stream タイムアウト対策固有のため省略 |
| SessionStart hook（リポジトリ状態バナー） | なし | Copilot に相当する機構が無いため省略 |

> ガードレール2種の仕組み・読み方・カスタマイズ方法は個別の解説ガイドを用意している：
> - git hooks（`.githooks/`）→ [git-hooks-guide.md](git-hooks-guide.md)
> - CI（GitHub Actions / `validate-conventions.yml`）→ [github-actions-guide.md](github-actions-guide.md)

## 前提

- [GitHub Copilot](https://github.com/features/copilot)（VS Code + Copilot Chat のエージェントモード。Copilot coding agent も併用可）
- GitHub リポジトリ（Issue / PR / Actions を使うため）
- **bash** が動く環境（git hooks 用。Windows は Git Bash で可）
- GitHub 操作手段のいずれか:
  - `gh` CLI（推奨。Copilot がターミナル経由で操作する）
  - [GitHub MCP サーバー](https://github.com/github/github-mcp-server)（VS Code の MCP 設定に登録している場合）

## クイックスタート

### 1. テンプレートをプロジェクトにコピー

```bash
# このリポジトリを取得
git clone https://github.com/Sakuya398-Yamada/issue-driven-dev-starter.git

# 新規 or 既存プロジェクトのルートにコピー
cp -r issue-driven-dev-starter/template-copilot/. /path/to/your-project/
```

> 既存プロジェクトに `.github/copilot-instructions.md` や `.github/workflows/` が既にある場合は、上書き前に差分を確認してマージすること。

### 2. プレースホルダーを埋める

コピーしたファイル内の `<...>` と `TODO` コメントを自分のプロジェクトに合わせて置き換える：

| ファイル | 置き換える内容 |
|---------|---------------|
| `.github/copilot-instructions.md` | プロジェクト名・概要 |
| `.github/instructions/tech-stack.instructions.md` | 技術スタック・開発環境・コマンド |
| `.github/instructions/coding-standards.instructions.md` | 言語・命名規約・ディレクトリ構成 |
| `.github/instructions/workflow-feedback.instructions.md` | 知見ボードIssue番号（手順5で作成後に記入） |

Copilot Chat に「`<...>` プレースホルダーと TODO コメントを探して、このプロジェクトに合わせて埋めるのを手伝って」と頼むのが早い。

### 3. git hooks を有効化

```bash
git config core.hooksPath .githooks
chmod +x .githooks/commit-msg .githooks/pre-push   # 実行権限が落ちている場合
```

> **重要**: `core.hooksPath` はリポジトリローカル設定なので、**クローンした各開発者が個別に実行する必要がある**。README やオンボーディング手順に含めておくとよい。ローカル hooks が効かない環境（Copilot coding agent・設定忘れ）は CI（`validate-conventions.yml`）が拾う。
>
> git hooks の仕組み自体に馴染みがない場合は [git-hooks-guide.md](git-hooks-guide.md)、CI 側は [github-actions-guide.md](github-actions-guide.md) を参照。

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
  --body "ワークフロー全体（/issue-start の手順、.github/instructions/*、copilot-instructions.md、git hooks、CI、prompts 等）への気づきを累積する常時Open Issue。運用規約は .github/instructions/workflow-feedback.instructions.md 参照。"
```

発行された Issue 番号を `.github/instructions/workflow-feedback.instructions.md` の「Issue番号」に記入する。

### 6. コミットして動作確認

```bash
git add .github/ .githooks/
git commit -m "chore: Issue駆動開発ワークフローを導入"
```

動作確認：

1. **instructions の適用**: Copilot Chat で「このプロジェクトのブランチ命名規約は？」と聞くと `git-conventions.instructions.md` の内容が返る
2. **プロンプトファイル**: Copilot Chat（エージェントモード）で `/` を入力すると `issue-start` が候補に出る
3. **commit-msg hook**: `git commit -m "test"` はブロック、`git commit -m "chore: 動作確認 #1"` は通る
4. **pre-push hook**: `test-branch` のような名前のブランチは push でブロック、`feature/#1-something` は通る
5. **CI**: 適当なPRを作ると `validate-conventions` チェックが走る

> 注意: git hooks は Claude 版と異なり **人間のコミット・push も等しく検証する**（Copilot のツール呼び出しだけでなくローカルの git 操作全体に効く）。緊急時の `--no-verify` は規約上バイパス禁止としているが、機械的には可能なので CI を最終防衛線とする。

### 7. 最初の Issue で回してみる

1. GitHub 上で Issue を作成する。テンプレートに含まれる **Issueテンプレート**（`.github/ISSUE_TEMPLATE/`、feature / bug / refactor / docs の4種）を使うと、背景・目的 / 要件（やること・やらないこと） / 完了条件（DoD）が最初から揃う（規約の詳細は `git-conventions.instructions.md` の「Issue」節）
2. VS Code の Copilot Chat を**エージェントモード**に切り替えて:

   ```
   /issue-start #1
   ```

3. あとは Phase 1〜8 が順に進む。設計承認・スコープ外問題の起票・知見ボード追記など、要所でユーザー確認が入る

## Copilot coding agent で使う場合

github.com 上で Issue を Copilot にアサインする使い方（Copilot coding agent）でも、このテンプレートはそのまま効く：

- coding agent は `.github/copilot-instructions.md` と `.github/instructions/*.instructions.md` を自動で読み込み、規約（1 Issue = 1 PR、コミットメッセージ、PR本文フォーマット等）に従う
- ブランチ作成・PR作成は coding agent が自動で行う。ブランチ名は `copilot/*` になるため、ブランチ名規約・コミットのIssue番号必須は**免除**される（`claude/*` と同じ扱い）
- ローカル git hooks は coding agent には効かないが、CI（`validate-conventions.yml`）がPR上で規約を検証する
- `/issue-start` の対話的な Phase（設計承認・スコープ外起票のY/E/N確認等）は coding agent では省略される。**要所で人間が判断するフローを重視するなら、VS Code のエージェントモード + `/issue-start` を使う**こと

## ワークフローの全体像

```
ユーザー: Issue作成 → /issue-start #N（VS Code Copilot Chat エージェントモード）
   │
   ▼
Phase 1  Issue分析・不足確認・自動補完（不足があれば質問して停止）
Phase 2  ラベル付与・ブランチ作成
Phase 3  コード探索（類似機能・アーキテクチャ・影響範囲の3観点）※bug/docs はスキップ可
Phase 4  設計案の比較（最小変更・クリーン・バランスの2〜3案）→ ユーザー承認
Phase 5  実装・コミット                    ← commit-msg hook が規約を強制
Phase 6  セルフレビュー（シンプルさ・バグ・規約の3観点）
Phase 7  PR作成（closes #N 付き）          ← pre-push hook + CI が規約を強制
Phase 8  Issueへ実装メモ・ハマりどころを記録 ＋ 知見ボード追記
   │
   ▼
ユーザー: PR確認・マージ → Issue自動クローズ
```

横断ルール: スコープ外の問題を見つけたら**その場で直さず**、ユーザー確認を挟んで子Issueとして起票（Phase 3/5/6 末尾）。

## ファイル構成

```
template-copilot/
├── .github/
│   ├── copilot-instructions.md          # コア原則＋instructions への索引（全リクエストに自動適用）
│   ├── ISSUE_TEMPLATE/                  # Issueテンプレート（feature / bug / refactor / docs）
│   ├── instructions/
│   │   ├── git-conventions.instructions.md       # ブランチ・コミット・PR・Issue・ラベル規約
│   │   ├── coding-standards.instructions.md      # コーディング規約（要カスタマイズ）
│   │   ├── tech-stack.instructions.md            # 技術スタック（要カスタマイズ）
│   │   ├── workflow-feedback.instructions.md     # 知見ボード運用規約
│   │   └── documentation-policy.instructions.md  # ドキュメントの書き分け方針
│   ├── prompts/
│   │   └── issue-start.prompt.md        # /issue-start 本体（8 Phase を1ファイルに凝縮）
│   └── workflows/
│       └── validate-conventions.yml     # ブランチ名・コミット規約のCI検証
└── .githooks/
    ├── commit-msg                       # コミット規約の強制（ローカル）
    └── pre-push                         # ブランチ名規約の強制（ローカル）
```

## カスタマイズ

基本的な考え方は [docs/customization.md](customization.md)（Claude 版）と同じ。Copilot 版でファイルの対応先が変わる点だけ挙げる：

### ブランチtype / コミットtype を増減する

規約は 4 箇所で同期している。変更時は必ず全部を揃えること：

| 箇所 | 何を変える |
|------|-----------|
| `.github/instructions/git-conventions.instructions.md` | 規約の文書（type表・例） |
| `.githooks/pre-push` | 正規表現 `^(feature|fix|refactor|docs)/#[0-9]+-.+` |
| `.githooks/commit-msg` | 正規表現 `^(feat|fix|refactor|test|docs|chore|style): .+` |
| `.github/workflows/validate-conventions.yml` | 上記2つと同じ正規表現（branch-name / commit-messages 両ジョブ） |

### Issue番号必須を緩和する

- ブランチ名の Issue 番号を任意にしたい → `pre-push` と CI の正規表現から `#[0-9]+-` を外す
- コミットの Issue 番号必須を外したい → `commit-msg` と CI の `issue_optional` 判定を常に 1 にする

### Phase を増減する

`.github/prompts/issue-start.prompt.md` の該当 Phase セクションを直接編集する（Claude 版と違い 1 ファイル構成）。スキップ条件も各 Phase セクション内に書いてある。

### 対象ファイルを絞った規約を追加する

`.github/instructions/` に新しい `*.instructions.md` を追加し、frontmatter の `applyTo` にグロブを書く（例: `applyTo: "src/api/**/*.ts"`）。追加したら `copilot-instructions.md` の索引テーブルにも 1 行足す。
