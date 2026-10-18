---
applyTo: "**"
description: "ブランチ・コミット・PR・Issue・ラベル規約"
---

# Git 規約

## ブランチ命名

```
<type>/#<issue番号>-<kebab-case説明>
```

| type | 対応する Issue ラベル | 用途 |
|------|---------------------|------|
| `feature` | `feature` | 新機能開発 |
| `fix` | `bug` | バグ修正 |
| `refactor` | `refactor` | リファクタリング |
| `docs` | `docs` | ドキュメント |

すべて `main` から派生し、`main` にマージする。例: `feature/#1-add-user-model` / `fix/#5-fix-date-calculation`

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

例: `feat: ユーザーデータモデルを追加 #1` / `feat(api)!: レスポンス形式を v2 に変更 #12`

> **例外**: セッションブランチ（`claude/*` / `copilot/*`）上のコミットは Issue番号を省略可。typeプレフィックスは必須。git 自身が生成する件名（`Merge ...` / `Revert ...` / `fixup! ...` / `squash! ...`）は検証対象外。

## Pull Request

### スコープ原則（1 Issue = 1 PR）

- 1つのPRは**1つのIssueの完了条件（DoD）のみ**を満たす変更に限定する。スコープ外の問題は同じブランチ／PRで修正せず、`/issue-start` の提案フロー（Phase 3/5/6 末尾）に従って**別Issueとして起票**し、独立した PR で対応する
- 例外: 作業中のIssueを満たすために不可避な副次変更（例: 同ファイル内で参照先が変わる / 型定義の追従）はこの限りではないが、PR本文の「## 変更点」に明示する

### PR のタイトルと本文

- タイトル: `<type>: <簡潔な説明> #<issue番号>`
- `## 概要`: 変更内容の要約（1〜3行）
- `## 変更点`: 具体的な変更のリスト
- `## テスト`: テスト方法・結果
- `closes #<issue番号>`: マージ時にIssueを自動クローズ（マージ後に行う DoD が残るなら `refs #<issue番号>` にし、終えてから手でクローズする。`/issue-start` Phase 7）

## Issue

### Issue のタイトルと本文

- タイトル: `<ラベル名>: <簡潔な説明>`（例: `feature: ユーザー設定画面を追加` / `bug: 日付計算が月末にずれる`）
- **背景・目的**: なぜこの作業が必要か
- **要件**: やること／やらないこと
- **完了条件（DoD）**: チェックリスト形式
- **未確定事項**: 要確認な仕様（あれば）

### 粒度

1 Issue = 1 PR なので、Issue の粒度がそのまま PR の粒度と `/issue-start` 1 回分の作業量になる。粒度が揺れるとレビュー負荷と手戻りも揺れるため、以下を既定とする。

<!-- TODO: プロジェクトの規模に合わせて「作業量」の目安を調整する -->

| 観点 | 既定 |
|------|------|
| 目的 | 1 Issue に目的は 1 つ。「背景・目的」が 1〜2 文で書ける |
| 作業量 | `/issue-start` 1 セッションで Phase 1〜8 を完走できる量。目安: 変更ファイル 10 個以内・差分 300 行以内 |
| 完了条件 | 単独で検証可能（テスト・動作確認・目視のいずれかで「できた／できていない」を判定できる） |
| 独立性 | 他 Issue の完了を待たずに着手できる。待つ必要があるなら本文に `依存: #N` を明記する |

分ける／分けないの判定表、親Issue・sub-issue の扱い、要望からの分割・起票は `/issue-plan`（`.github/skills/issue-plan/SKILL.md`「粒度の判定」）が正本。迷ったら **「このIssueのPRだけをマージしても、壊れず・単独で説明できるか」** で判定する。Yes なら粒度は適切。

- 先に別 Issue の完了が必要な場合は、本文の「## 関連Issue」に `依存: #N` と書く。`/issue-start` Phase 1 で依存先が未完了なら、着手前にユーザーに確認する

### ラベル

作業ラベルは `feature` / `bug` / `refactor` / `docs`（ブランチ type との対応は「ブランチ命名」の表）。補助ラベルは `meta`（知見ボード等のメタ情報）、`question`（要確認・議論）、`priority:high` / `priority:medium` / `priority:low`。色と作成コマンドはテンプレート元の Copilot 版クイックスタートにある。

## 自動検証

規約は三層で機械的に検証される。3 箇所は同じ正規表現を共有しているので、規約を変えるときは全部を揃える（`copilot-instructions.md`「自動ガードレール」）。

| 層 | 検証対象 | 効く範囲 |
|---|---|---|
| preToolUse hook: `.github/hooks/validate-branch-name.sh` / `validate-commit-message.sh`（`validate-conventions.json` で登録） | `git checkout -b/-B/--orphan`、`git switch -c/-C/--create`、`git branch <name>`、`git worktree add -b` の新ブランチ名。`git commit` の `-m` / `-am` / `--message` / heredoc（`-F -`）で渡す件名 | Copilot cloud agent / Copilot CLI / VS Code の Copilot（エージェントのツール呼び出し） |
| git hooks: `.githooks/commit-msg` / `.githooks/pre-push` | コミットメッセージ（コミット時）、ブランチ名（push 時。git にはブランチ作成時の hook が無い） | ローカルの git 操作すべて（人間にもエージェントにも効く） |
| CI: `.github/workflows/validate-conventions.yml` | PR のブランチ名と全コミットの件名 | hooks が効かない環境のセーフティネット |

`git commit -F <file>` や `--amend --no-edit` のように件名を取り出せない形は、preToolUse hook では誤検知を避けるため通す（`commit-msg` hook と CI が拾う）。preToolUse hook は件名を、その `git commit` 自身のオプション（次の改行・`;`・`&`・`|` まで）と同じ行で開いた heredoc の先頭行からだけ取り出すので、`git add ... && git commit -F - <<'MSG'` のような連結もそのまま検証できる。

preToolUse hook が検証できなかったとき（JSON パーサーの jq / node / python3 がどれも無い、hook がエラーで終わる）は、検証しないまま通さずにコマンドを止める（パーサーが無いときは hook 自身が exit 2、エラーで終わった hook は Copilot が止める）。時間切れだけは Copilot の仕様で止められずに通るので、git hooks と CI が拾う。止められたら、理由に出る hook のエラーを直すか、直せなければユーザーに報告する。
