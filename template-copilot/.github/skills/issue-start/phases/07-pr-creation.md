# Phase 7: PR作成

> **Copilot cloud agent の場合**: PR は cloud agent が draft で自動作成する。本文を下記フォーマットに揃え、`closes #<issue番号>` を含めることだけ行う。

## push 前チェック

1 つでも該当すれば対応してから進む：

- [ ] `git status --short` に一時ファイル・生成物・ログ・個人設定が含まれていない
  - 含まれていれば `.gitignore` を確認・修正し、`git rm --cached <path>` で追跡から外す
- [ ] `git log origin/main..HEAD --stat` にこの Issue と無関係な変更（他 Issue の修正・無関係なリファクタ）が混ざっていない
  - 混ざっていれば `git reset --soft <正しい基点>` で巻き戻して staging を整理し直す
- [ ] テスト・リントが最新のコミットで通っている（Phase 6 の手順 1 以降に変更があれば再実行）

## 手順

1. リモートにブランチをプッシュする（`pre-push` hook がブランチ名を検証する）：

   ```bash
   git push -u origin <ブランチ名>
   ```

2. `main` への PR を作成する（`git-conventions.instructions.md`「Pull Request」）。GitHub MCP の `create_pull_request`、または `gh pr create --title ... --body-file <tmp>`

   - タイトル: `<type>: <説明> #<issue番号>`
   - 本文:

     ```
     ## 概要
     （1〜3 行）

     ## 変更点
     - ...

     ## テスト
     - 実行したコマンドと結果（例: `npm test` 42 passed）
     - 手動確認した内容 / 未検証の項目

     closes #<issue番号>
     ```

   - レビューを待たせずに先に見せたい場合は draft で作成し、Phase 8 の記録が終わったら ready にする
   - CI（`validate-conventions.yml`）がブランチ名とコミットメッセージを再検証する。赤くなったら規約に合わせて直す

3. 作成された PR の URL をユーザーに返す

## ワークフロー改善余地のメモ（Phase 8 向け）

PR 作成フロー自体への気づき（`closes #N` の付け忘れ誘因、push 周りのハマりどころ、本文テンプレートに足したい項目など）があれば短文メモで控え、Phase 8 で知見ボードに書く。
