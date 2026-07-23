---
name: 知見ボード（meta）
about: ワークフロー改善の知見を累積する常時Open Issueを作成する（セットアップ時に1回だけ使う）
title: "meta: ワークフロー改善の知見ボード"
labels: meta
---

ワークフロー全体（`/issue-start` の手順、`.github/instructions/*`、`copilot-instructions.md`、git hooks、CI、prompts 等）への気づきを累積する常時Open Issue。運用規約は `.github/instructions/workflow-feedback.instructions.md` を参照。

<!--
起票後、発行されたIssue番号を以下に記入すること：
- .github/instructions/workflow-feedback.instructions.md の「Issue番号」
-->

## 運用

- **常時Open**（クローズしない）
- 気づきは `/issue-start` Phase 8 の最後に、ユーザー確認を挟んでコメントとして追記される（1気づき = 1コメント）
- 溜まったコメントはユーザーが独立した改善Issueへ昇格させ、元コメントの末尾に `✅ Issue #<番号> で対応` を追記する

## コメントの記入フォーマット

```markdown
## ワークフロー改善余地 [#<作業Issue番号>]
**発生Phase**: Phase N（例: Phase 5 実装中）

**気づき**: 何が非効率だった／躓いた／改善の余地があったか

**現状の動作**: 現在のワークフローではどう進んだか

**改善案**: どう変えると良いか

**重要度**: Low / Medium / High
```
