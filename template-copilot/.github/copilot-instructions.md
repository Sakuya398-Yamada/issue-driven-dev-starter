# <プロジェクト名>

<!-- TODO: プロジェクトの1〜2行説明に置き換える -->
<プロジェクトの概要をここに書く>

## 開発方針

- **Issue駆動開発**: すべての作業はGitHub Issueから始める。Issueが唯一の情報源
- **1 Issue = 1 PR**: 作業中のIssueスコープ外の変更を同じPRに混ぜない
- **スコープ外問題は起票提案**: 作業中に当該Issueのスコープ外の問題（別バグ・改善余地・技術負債）を見つけたら、その場で修正せずユーザーに Issue起票を提案する。承認後に子Issueを作成し、親Issueへ記録する
- **推測しない、ただし調べられることは自分で調べる**: 仕様・要件・設計の分岐のように「ユーザーが決めること」は質問する。コードの構造やライブラリの使い方のように「調べれば分かること」はツールで確認してから進む。ツール呼び出しの回数を理由に手を止めない
- **確認ポイントで止まる**: 設計承認（Phase 4）・スコープ外問題の起票・知見ボードや外部リポジトリへの投稿は、ユーザーの Y/E/N を得てから行う。それ以外の場面では進捗を 2〜3 行で共有しつつ作業を続ける
- **検証してから完了と言う**: テスト・リント・動作確認で結果を確かめてから報告する。検証できなかった項目はその旨を明記する
- **過剰設計しない**: Issue の完了条件を満たす最小の変更にとどめる。頼まれていない抽象化・設定項目・将来対応は入れない
- **コンテキストは必要な分だけ**: 全文理解を目的にファイルを丸読みしない。検索で当たりを付けて局所的に読み、横断調査はサブエージェントに委譲して要約だけ受け取る（詳細は `context-efficiency.instructions.md`）
- **Issueへの記録**: 実装中に判明した技術情報や判断はIssueにコメントとして残す
- **過去Issueの参照**: 関連する過去のIssueから情報を収集し、実装に活かす

## 詳細規約（`.github/instructions/`）

具体的な規約は `.github/instructions/*.instructions.md` に分割してある。各ファイルは frontmatter の `applyTo` に基づいて Copilot に自動適用される。**このファイル（copilot-instructions.md）は索引・コア原則のみに保ち、詳細規約は instructions 側に書く**（運用方針は `documentation-policy.instructions.md`）。

| ファイル | 内容 |
|---------|------|
| `git-conventions.instructions.md` | ブランチ・コミット・PR・Issue・ラベル規約 |
| `coding-standards.instructions.md` | 言語規約・命名・ディレクトリ構成・コメント方針（要カスタマイズ） |
| `tech-stack.instructions.md` | 技術スタック・開発環境・コマンド（要カスタマイズ） |
| `context-efficiency.instructions.md` | コンテキスト効率・ファイル読解・サブエージェント委譲 |
| `workflow-feedback.instructions.md` | 知見ボード運用、テンプレート元への還元・更新取り込み |
| `documentation-policy.instructions.md` | このファイル・instructions・skills・agents・hooks の書き分け方針 |

## 開発フロー

1. **Issue作成（ユーザー）**: GitHub上でIssueを作成し、背景・要件・完了条件を記載。要望からの分割・起票は `/issue-plan` に任せてもよい（粒度の基準は `git-conventions.instructions.md`「粒度」）
2. **Issue指定（ユーザー）**: VS Code の Copilot Chat（エージェントモード）または Copilot CLI で `/issue-start #<番号>` を実行
3. **ブランチ作成＆実装（Copilot）**: Issueと関連する過去Issueを読み取り、ブランチ作成・設計・実装・レビュー
4. **PR作成（Copilot）**: `closes #<issue番号>` を含めたPRを作成し、Issueに実装メモを記録
5. **最終確認＆マージ（ユーザー）**: PRを承認・マージ。Issueが自動クローズされる

`/issue-start` と `/issue-plan` は Agent Skills（`.github/skills/<name>/SKILL.md`）として定義してある。各 Phase の詳細は `.github/skills/issue-start/phases/` を参照。1 セッションで扱う Issue は 1 件を基本とし、別の Issue に移るときは新しいチャットで始める。

> **Copilot cloud agent（github.com で Issue を Copilot にアサインする使い方）の場合**: ブランチ作成（Phase 2）と PR 作成（Phase 7）は cloud agent が自動で行う（ブランチ名は `copilot/*`、PR は draft）。サブエージェントと対話的な確認は使えないので、設計案と前提は PR 本文に書き、スコープ外で見つけた問題は起票せず PR 本文に列挙する。それ以外の方針（1 Issue = 1 PR、コミットメッセージ規約、PR本文フォーマット）はそのまま従う。

### スコープ外問題の取り扱い

作業中にスコープ外の問題を検出した場合は、以下のいずれかに当てはまるものだけを起票候補として扱う：

- **起票する**: 機能不具合・仕様乖離・データ誤り・ユーザー体験を損なう振る舞い・複数機能横断の類似問題
- **起票しない**: コードスタイルの好み・影響の無いリファクタ案・当該Issueの DoD に含まれる範囲・既存Issueの重複

起票前に既存Issueを検索（GitHub MCP の `search_issues` または `gh issue list --search`）して重複を確認し、ユーザー確認（Y=そのまま起票 / E=編集して起票 / N=起票しない）を挟んでから起票する。子Issue は GitHub の sub-issue として親に紐づけ、Phase 8 で親Issueにも一覧をコメントする。

## 自動ガードレール

規約は「AIへのお願い」だけでなく、三層で機械的に検証される：

| 層 | 仕組み | 効く範囲 |
|---|---|---|
| preToolUse hook（`.github/hooks/validate-conventions.json` + `validate-*.sh`） | エージェントがブランチ作成・`git commit` を実行する直前に検証し、違反を拒否する | Copilot cloud agent / Copilot CLI / VS Code の Copilot（エージェントのツール呼び出しのみ） |
| git hooks（`.githooks/`、`git config core.hooksPath .githooks`） | `commit-msg`: コミットメッセージ規約、`pre-push`: ブランチ名規約 | ローカルの git 操作すべて（人間にもエージェントにも効く） |
| CI（`.github/workflows/validate-conventions.yml`） | PR 上でブランチ名とコミットメッセージを再検証する | hooks が効かない環境のセーフティネット |

規約は文章で念押ししても長いセッションでは守られなくなるため、機械判定できるものは hook で強制する。拒否されたら規約に合わせて直す。`--no-verify` や hook の無効化で回避しない。

## ドキュメントの更新

実装の過程で規約・フロー・技術スタックに変更が生じたら、該当するドキュメントを同じ PR で更新する：

- 技術スタックが決定・変更されたとき → `tech-stack.instructions.md`
- コーディング規約が追加されたとき → `coding-standards.instructions.md`
- Git/PR/Issue規約が変わったとき → `git-conventions.instructions.md`（hooks と CI の正規表現も揃える）
- 開発フロー全体が変わったとき → このファイル

`AGENTS.md` を併用する場合（Copilot CLI / cloud agent / VS Code / code review が読む）、内容をこのファイルと重複させない。両方が追加で読み込まれる。
