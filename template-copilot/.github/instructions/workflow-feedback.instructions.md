---
applyTo: "**"
description: "ワークフロー改善の知見ボード運用規約"
---

# ワークフロー改善の知見ボード

`/issue-start` セッションで得た **ワークフロー改善の気づき** を累積する専用Issueの運用規約と、テンプレート元との双方向のやり取り（**知見の還元** と **テンプレート更新の取り込み**）の判定基準。手順そのものは常駐させず、`/issue-start` の phases と `/template-update` skill に置いてある（各節の「手順の正本」）。

## 知見ボードIssue

- **Issue番号**: #<知見ボードIssue番号> <!-- TODO: セットアップ時に番号を記入 -->
- **タイトル**: `meta: ワークフロー改善の知見ボード`
- **ラベル**: `meta`
- **運用**: 常時Open（クローズしない）。溜まったコメントを改善 Issue へ昇格させる棚卸しはユーザーが行う（手順は知見ボード Issue 本文。雛形は `.github/ISSUE_TEMPLATE/workflow-feedback.md`「棚卸し」）

## テンプレート元の情報

このプロジェクトのワークフロー（`.github/copilot-instructions.md` / `.github/instructions/` / `.github/skills/` / `.github/agents/` / `.github/hooks/` / `.githooks/`）は [issue-driven-dev-starter](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter) の Copilot 版テンプレート（`template-copilot/`）から生成されている。テンプレート元との接点は `.github/template-version`（`repo=<owner/repo>` と `version=vX.Y.Z`。版はテンプレート元の Release タグと同一書式）に集約してあり、フォークした独自テンプレートを使う場合は `repo` を書き換える。

## 何を書くか

ワークフロー全体（`/issue-start` / `/issue-plan` の手順、`.github/instructions/*`、`copilot-instructions.md`、skills、agents、hooks、CI、MCP 運用等）への気づきを集約する。

| 集約対象 | 集約対象外 |
|---------|-----------|
| ワークフローの冗長・曖昧さ | 個別Issueの実装メモ（→ 当該Issueのコメント） |
| スキル定義（SKILL.md / phases）・agents の改善余地 | アプリ仕様そのもの（→ 該当Issueや新規Issue） |
| 規約・ガードレール追加候補 | コード上の個別バグ（→ 別Issueとして起票） |
| MCP / gh CLI 運用のハマりどころ | コードスタイルの好み |

## いつ書くか

`/issue-start` **Phase 8 の最後**（個別Issueへの実装メモ記録が終わった後）に、その回のセッションで見つけた気づきがあれば書き込む。Phase 5〜7 で気づいたことはその場で直さず短文メモに留め、Phase 8 で棚卸しする。

- **気づきが無い場合はスキップしてよい**（「特になし」と明示コメントしなくてよい）
- **ユーザー確認を挟んでから書き込む**（無人書き込みはしない）
- 手順の正本: `phases/08-issue-recording.md` 手順 5（候補の提示フォーマットとコメント本文テンプレート）

## 重要度の判定基準

| 重要度 | 目安 |
|--------|------|
| **High** | 毎セッション再発する／セッション失敗の直接原因／ガードレール追加で即座に解消できる |
| **Medium** | 数回に一度発生する／手順が冗長・曖昧で毎回判断コストが掛かる |
| **Low** | 1回限りの気づき／将来あると便利レベル／ユーザー影響が軽微 |

## テンプレート元への還元（upstream feedback）

知見ボードに書いた気づきのうち **テンプレート汎用のもの** は、このプロジェクト内で閉じさせず、**テンプレート元リポジトリの Issue として起票**する。テンプレート側はその Issue を通常の `/issue-start` フローで精査・反映し、リリースを切る。リリースは後述の更新チェックでこのプロジェクトにも戻ってくる。

手順の正本: `phases/08-issue-recording.md` 手順 6（抽象化 → 重複チェック → ユーザー確認 → 起票 → 元コメントへの印）。

### 還元する / しないの判定

| テンプレート汎用（還元する） | プロジェクト固有（還元しない） |
|---------------------------|----------------------------|
| `/issue-start` の手順・Phase 構成・ユーザー確認の粒度 | `tech-stack.instructions.md` / `coding-standards.instructions.md` の中身 |
| `git-conventions` / `workflow-feedback` / `documentation-policy` の規約そのもの | プロジェクト固有の MCP 構成・VS Code 設定 |
| hooks（preToolUse / git hooks）/ CI（`validate-conventions.yml`）/ agents の挙動・判定ロジック・出力上限 | 特定言語・フレームワークに閉じたハマりどころ（「言語別の例が欲しい」のように一般化できる要望は汎用） |
| Issueテンプレート・セットアップ手順・プレースホルダーの不備 | チーム運用の都合による独自ルール |

迷ったら「**テンプレートを新規に使う別プロジェクトでも同じ問題が起きるか**」で判定する。起きるなら汎用。

### 還元 Issue に含めないもの

テンプレート元は **公開リポジトリ** である。以下は書かず、ワークフロー手順のレベルに抽象化する：

- プロジェクトのコード断片・ファイルパス・内部識別子・URL
- 顧客名・社内システム名・人名
- 認証情報・環境変数の値
- 非公開プロジェクトの場合はリポジトリ名も省略し「非公開プロジェクト」と書く

## テンプレート更新の取り込み（update check）

Claude Code 版と違い自動のバナーは出さず、`/issue-start` の Phase 1 手順 0.5 で最新リリースタグを取得して `.github/template-version` の `version` と比較する。

- **作業中の Issue のブランチでテンプレートを直接更新しない**（1 Issue = 1 PR）。更新は `refactor: テンプレートを vX.Y.Z に更新` Issue を起票し、独立した PR で取り込む
- 検知と更新用 Issue の起票の正本: `phases/01-issue-analysis.md` 手順 0.5（比較コマンド、セッションで一度だけ聞く確認、Issue 本文に含める項目）
- 取り込み（更新用 Issue の Phase 5）の正本: `.github/skills/template-update/SKILL.md`（`/template-update`。3-way マージの定型手順と DoD を含む）

## 自動化しないこと

- **無人投稿はしない**: 知見ボードへのコメントはユーザー確認（Y/E/N）を挟む。テンプレート元への起票は、それとは別に抽象化した本文で改めて確認を取る
- **テンプレートの無人更新はしない**: 更新チェックは「通知して更新用 Issue の起票を提案する」までで、ファイルの書き換えは更新用 Issue の `/issue-start` で行う
- **知見ボードIssueを自動クローズしない**（常時Open運用）。**過去セッションからの遡及集約も行わない**（未来のセッションから運用する）
