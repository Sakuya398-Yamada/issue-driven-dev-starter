---
applyTo: "**"
description: "ブランチ・コミット・PR・Issue・ラベル規約"
---

# Git 規約

## ブランチ命名

```
<type>/#<issue番号>-<kebab-case説明>
```

| type | 用途 | 派生元 | マージ先 |
|------|------|--------|---------|
| `feature` | 新機能開発 | main | main |
| `fix` | バグ修正 | main | main |
| `refactor` | リファクタリング | main | main |
| `docs` | ドキュメント | main | main |

例:

```
feature/#1-add-user-model
fix/#5-fix-date-calculation
refactor/#10-refactor-api-client
```

- `<kebab-case説明>` は **小文字英数字とハイフンのみ**（`add-user-model`）。大文字・アンダースコア・連続ハイフンは不可
- `#<issue番号>` は対象 Issue の番号。ブランチは必ず Issue に紐づく

> **例外**: エージェントのセッションブランチ **`claude/*`**（Claude Code on the web / GitHub Actions）と **`copilot/*`**（Copilot cloud agent、旧 coding agent）は、ツール側が自動命名するためこの規約の対象外。`main` / `master` / `develop` もそのまま使う。

## コミットメッセージ

```
<type>: <subject> #<issue番号>
```

[Conventional Commits](https://www.conventionalcommits.org/ja/v1.0.0/) 互換。任意で **scope** と **破壊的変更マーカー `!`** を付けられる（`<type>(<scope>)!: <subject> #<issue番号>`）。`!` を付けたコミットはリリース時に major 版を上げる扱いになるので、後方互換を壊す変更にだけ使う。

| type | 説明 |
|------|------|
| `feat` | 新機能追加 |
| `fix` | バグ修正 |
| `refactor` | リファクタリング |
| `test` | テスト追加・修正 |
| `docs` | ドキュメント |
| `chore` | ビルド・設定変更 |
| `style` | コードスタイル修正（動作に影響なし） |

例:

```
feat: ユーザーデータモデルを追加 #1
fix: 日付計算の境界条件を修正 #5
test: APIクライアントのユニットテスト追加 #8
feat(api)!: レスポンス形式を v2 に変更 #12
```

> **例外**: セッションブランチ（`claude/*` / `copilot/*`）上のコミットは Issue番号を省略可。typeプレフィックスは必須。git 自身が生成する件名（`Merge ...` / `Revert ...` / `fixup! ...` / `squash! ...`）は検証対象外。

## Pull Request

### スコープ原則（1 Issue = 1 PR）

- 1つのPRは**1つのIssueの完了条件（DoD）のみ**を満たす変更に限定する
- 作業中に当該Issueのスコープ外の問題を発見しても、同じブランチ／PRで修正しない
- スコープ外の問題は `/issue-start` の提案フロー（Phase 3/5/6 末尾）に従って**別Issueとして起票**し、独立した PR で対応する
- 例外: 作業中のIssueを満たすために不可避な副次変更（例: 同ファイル内で参照先が変わる / 型定義の追従）はこの限りではないが、PR本文の「## 変更点」に明示する

### タイトル

```
<type>: <簡潔な説明> #<issue番号>
```

### 本文に含める内容

- `## 概要`: 変更内容の要約（1〜3行）
- `## 変更点`: 具体的な変更のリスト
- `## テスト`: テスト方法・結果
- `closes #<issue番号>`: マージ時にIssueを自動クローズ

## Issue

### タイトル

```
<ラベル名>: <簡潔な説明>
```

例: `feature: ユーザー設定画面を追加` / `bug: 日付計算が月末にずれる`

### Issueに含める内容

- **背景・目的**: なぜこの作業が必要か
- **要件**: やること／やらないこと
- **完了条件（DoD）**: チェックリスト形式
- **未確定事項**: 要確認な仕様（あれば）

この構成は `.github/ISSUE_TEMPLATE/issue.md`（新規Issue）に Issueテンプレートとして用意してあり、GitHub 上で Issue を新規作成すると選択できる。ほかに知見ボード作成用の `workflow-feedback.md`（meta、セットアップ時に1回だけ使う）がある。テンプレートに沿わない Issue は空白Issueから作成してよい。

### 粒度

1 Issue = 1 PR なので、Issue の粒度がそのまま PR の粒度と `/issue-start` 1 回分の作業量になる。粒度が揺れるとレビュー負荷と手戻りも揺れるため、以下を既定とする。

<!-- TODO: プロジェクトの規模に合わせて「作業量」の目安を調整する -->

| 観点 | 既定 |
|------|------|
| 目的 | 1 Issue に目的は 1 つ。「背景・目的」が 1〜2 文で書ける |
| 作業量 | `/issue-start` 1 セッションで Phase 1〜8 を完走できる量。目安: 変更ファイル 10 個以内・差分 300 行以内 |
| 完了条件 | 単独で検証可能（テスト・動作確認・目視のいずれかで「できた／できていない」を判定できる） |
| 独立性 | 他 Issue の完了を待たずに着手できる。待つ必要があるなら本文に `依存: #N` を明記する |

**分ける／分けない の判定**:

| 分ける（複数 Issue にする） | 分けない（1 Issue に保つ） |
|---------------------------|--------------------------|
| 「やること」に目的の異なる項目が並ぶ（「○○を追加し、ついでに△△を直す」） | 片方だけ入れると動作しない・検証できない（型定義とその唯一の利用箇所など） |
| 層ごとに単独で検証できる（DB → API → UI をそれぞれ動作確認できる） | 層をまたいでも 1 画面・1 機能として縦に切った方が検証しやすい |
| 片方が先に完了しないともう片方の設計が決まらない（依存順に分け、後続に `依存: #N`） | 分けた片方が DoD 1 個・差分数十行で、PR として意味を成さない |
| 完了条件が 7 個を超える／ラベルが複数（`feature` と `refactor` 等）にまたがる | ― |

迷ったら **「このIssueのPRだけをマージしても、壊れず・単独で説明できるか」** で判定する。Yes なら粒度は適切。

### 依存関係と親Issue

- 先に別 Issue の完了が必要な場合は、本文の「## 関連Issue」に `依存: #N` と書く。`/issue-start` Phase 1 で依存先が未完了なら、着手前にユーザーに確認する
- 1 つの要望を 3 件以上に分割したときは、進捗管理用の **親Issue** を作ってよい。本文に子Issue のタスクリスト（`- [ ] #N <タイトル>`）を置く。親Issue 自体は実装対象ではないので `/issue-start` しない。子Issue 側は本文末尾に `親Issue: #N` と書く（スコープ外問題で起票する子Issue と同じ記法）
- 要望からの分割・起票は `/issue-plan`（`.github/skills/issue-plan/SKILL.md`）がこの粒度規約に沿って提案する。既存 Issue が大きすぎるときは `/issue-plan #N` で分割する

### ラベル

| ラベル | 説明 | 色 |
|--------|------|----|
| `feature` | 新機能 | `#0E8A16` |
| `bug` | バグ | `#D73A4A` |
| `refactor` | リファクタリング | `#F9D0C4` |
| `docs` | ドキュメント | `#0075CA` |
| `meta` | ワークフロー改善の知見ボード等、メタ情報用 | `#6B5B95` |
| `question` | 要確認・議論 | `#D876E3` |
| `priority:high` | 優先度高 | `#B60205` |
| `priority:medium` | 優先度中 | `#FBCA04` |
| `priority:low` | 優先度低 | `#C2E0C6` |

### ラベル → ブランチprefix 対応

| Issueラベル | ブランチprefix |
|-------------|---------------|
| `feature` | `feature/` |
| `bug` | `fix/` |
| `refactor` | `refactor/` |
| `docs` | `docs/` |

## 自動検証

規約は三層で機械的に検証される。3 箇所は同じ正規表現を共有しているので、規約を変えるときは全部を揃える（`copilot-instructions.md`「自動ガードレール」）。

| 層 | 検証対象 | 効く範囲 |
|---|---|---|
| preToolUse hook: `.github/hooks/validate-branch-name.sh` / `validate-commit-message.sh`（`validate-conventions.json` で登録） | `git checkout -b/-B/--orphan`、`git switch -c/-C/--create`、`git branch <name>`、`git worktree add -b` の新ブランチ名。`git commit` の `-m` / `-am` / `--message` / heredoc（`-F -`）で渡す件名 | Copilot cloud agent / Copilot CLI / VS Code の Copilot（エージェントのツール呼び出し） |
| git hooks: `.githooks/commit-msg` / `.githooks/pre-push` | コミットメッセージ（コミット時）、ブランチ名（push 時。git にはブランチ作成時の hook が無い） | ローカルの git 操作すべて（人間にもエージェントにも効く） |
| CI: `.github/workflows/validate-conventions.yml` | PR のブランチ名と全コミットの件名 | hooks が効かない環境のセーフティネット |

`git commit -F <file>` や `--amend --no-edit` のように件名を取り出せない形は、preToolUse hook では誤検知を避けるため通す（`commit-msg` hook と CI が拾う）。
