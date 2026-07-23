# <プロジェクト名>

<!-- TODO: プロジェクトの1〜2行説明に置き換える -->
<プロジェクトの概要をここに書く>

## 開発方針

- **Issue駆動開発**: すべての作業はGitHub Issueから始める。Issueが唯一の情報源
- **1 Issue = 1 PR**: 作業中のIssueスコープ外の変更を同じPRに混ぜない
- **スコープ外問題は起票提案**: 作業中に当該Issueのスコープ外の問題（別バグ・改善余地・技術負債）を発見した場合、**その場で修正せずユーザーに Issue起票を提案** する。承認後に子Issueを作成し、親Issueへリンクを記録する
- **推測しない**: 不明な仕様はユーザーに確認する
- **思考よりも対話**: 方針が定まらない場合、長時間の試行錯誤ではなくユーザーへの質問で解決する
- **中間報告**: 大きなファイルや複雑なコードを読み込んだ後は、理解した内容を 2〜3 行で要約し、次のアクションをユーザーに示してから進む
- **Issueへの記録**: 実装中に判明した技術情報や判断はIssueにコメントとして残す
- **過去Issueの参照**: 関連する過去のIssueから情報を収集し、実装に活かす

## 詳細規約（.github/instructions/）

具体的な規約は `.github/instructions/*.instructions.md` にモジュール分割している。各ファイルは frontmatter の `applyTo` に基づいて Copilot に自動適用される。**このファイル（copilot-instructions.md）は索引・コア原則のみに保ち、詳細規約は instructions 側に書く**（運用方針は `documentation-policy.instructions.md` 参照）。

| ファイル | スコープ |
|---------|---------|
| `git-conventions.instructions.md` | ブランチ・コミット・PR・Issue・ラベル規約 |
| `coding-standards.instructions.md` | 言語規約・命名・ディレクトリ構成・コメント方針 |
| `tech-stack.instructions.md` | 技術スタック・開発環境・コマンド |
| `workflow-feedback.instructions.md` | ワークフロー改善知見ボード運用 |
| `documentation-policy.instructions.md` | ドキュメント運用方針 |

## 開発フロー

1. **Issue作成（ユーザー）**: GitHub上でIssueを作成し、要件・設計・完了条件を記載
2. **Issue指定（ユーザー）**: VS Code の Copilot Chat（エージェントモード）で `/issue-start #<番号>` を実行
3. **ブランチ作成＆実装（Copilot）**: Issueと関連する過去Issueを読み取り、ブランチ作成・実装
4. **PR作成（Copilot）**: `closes #<issue番号>` を含めたPRを作成
5. **最終確認＆マージ（ユーザー）**: PRを承認・マージ。Issueが自動クローズされる

`/issue-start` の各Phase詳細は `.github/prompts/issue-start.prompt.md` 参照。

> **Copilot coding agent（github.com で Issue を Copilot にアサインする使い方）の場合**: Phase 2（ブランチ作成）と Phase 7（PR作成）は coding agent が自動で行う（ブランチ名は `copilot/*` になる）。それ以外の方針（1 Issue = 1 PR、スコープ外問題の混ぜ込み禁止、コミットメッセージ規約、PR本文フォーマット）はこのファイルと instructions の規約にそのまま従うこと。

### スコープ外問題の取り扱い

作業中にスコープ外の問題を検出した場合は、以下のいずれかに当てはまるものだけを起票候補として扱う：

- **起票する**: 機能不具合・仕様乖離・データ誤り・ユーザー体験を損なう振る舞い・複数機能横断の類似問題
- **起票しない**: コードスタイルの好み・影響の無いリファクタ案・当該Issueの DoD に含まれる範囲・既存Issueの重複

起票前に必ず既存Issueを検索（GitHub MCP の `search_issues` または `gh issue list --search`）して重複をチェックし、ユーザー確認（Y=そのまま起票 / E=編集して起票 / N=起票しない）を挟んでから起票する。起票した子Issueは Phase 8 で親Issueへコメント記録する。

## ガードレール（git hooks + CI）

規約は「AIへのお願い」だけでなく機械的にも検証される：

- **ローカル git hooks**（`.githooks/`、`git config core.hooksPath .githooks` で有効化）
  - `commit-msg`: コミットメッセージ規約 `<type>: <subject> #<issue>` を検証（`copilot/*`・`claude/*` ブランチ上はissue番号省略可）
  - `pre-push`: ブランチ名規約 `<feature|fix|refactor|docs>/#<issue>-<desc>` を検証
- **CI**（`.github/workflows/validate-conventions.yml`）: PR上でブランチ名とコミットメッセージを再検証する。ローカルhooksが効かない環境（Copilot coding agent 等）のセーフティネット

違反はコミット／push／CIで失敗する。意図的にバイパス（`--no-verify` 等）しない。

## ドキュメントの自動更新

実装の過程で規約・フロー・技術スタックなどに変更が生じた場合、以下のドキュメントを適宜更新する：

- **`.github/copilot-instructions.md`**: コア原則（このファイル）
- **`.github/instructions/*.instructions.md`**: 個別の詳細規約

更新が必要になるケース例：
- 技術スタックが決定・変更されたとき → `tech-stack.instructions.md`
- コーディング規約が追加されたとき → `coding-standards.instructions.md`
- Git/PR/Issue規約が変わったとき → `git-conventions.instructions.md`
- 開発フロー全体が変わったとき → このファイル
