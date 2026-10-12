---
name: 知見ボード（meta）
about: ワークフロー改善の知見を累積する常時Open Issueを作成する（セットアップ時に1回だけ使う）
title: "meta: ワークフロー改善の知見ボード"
labels: meta
---

ワークフロー全体（`/issue-start` / `/issue-plan` の手順、`.github/instructions/*`、`copilot-instructions.md`、skills、agents、hooks、CI、MCP 運用等）への気づきを累積する常時Open Issue。運用規約は `.github/instructions/workflow-feedback.instructions.md` を参照。

<!--
起票後、発行されたIssue番号を以下に記入すること：
- .github/instructions/workflow-feedback.instructions.md の「Issue番号」
-->

## 運用

- **常時Open**（クローズしない）
- 気づきは `/issue-start` Phase 8 の最後に、ユーザー確認を挟んでコメントとして追記される（1気づき = 1コメント）
- 溜まったコメントの棚卸し（改善Issueへの昇格）は下記「棚卸し」の手順でユーザーが行う
- **テンプレート汎用**の気づき（別プロジェクトでも同じ問題が起きるもの）は、プロジェクト固有情報を除いた上でテンプレート元リポジトリに Issue として還元する（`.github/instructions/workflow-feedback.instructions.md`「テンプレート元への還元」参照）

## 棚卸し（ユーザー側）

コメントが溜まってきたら、ユーザーが手動で以下を行う：

1. 独立した改善Issue として起票する（通常の Issue ラベル: `feature` / `refactor` / `docs` 等を付与）
2. 元コメントを編集し、末尾に `✅ Issue #<昇格先Issue番号> で対応` を追記する
3. 昇格後のIssueは通常の `/issue-start` フローで実装する
4. 実装した改善が **テンプレート汎用** で、まだ還元していなければ、`/issue-start` Phase 8 手順 6 の還元フローでテンプレート元にも Issue を起票する（Phase 8 で還元済みなら不要）

これにより、どの知見が回収済み・還元済みかを一目で追跡できる。

## コメントの記入フォーマット

```markdown
## ワークフロー改善余地 [#<作業Issue番号>]
**発生Phase**: Phase N（例: Phase 5 実装中）

**気づき**: 何が非効率だった／躓いた／改善の余地があったか

**現状の動作**: 現在のワークフローではどう進んだか

**改善案**: どう変えると良いか

**書き先**: hook / 手順修正 / pitfalls / rules

**重要度**: Low / Medium / High

**還元先**: プロジェクト固有 / テンプレート汎用（未還元）
```
