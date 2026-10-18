# Phase 7: PR作成

> **Copilot cloud agent の場合**: PR は cloud agent が draft で自動作成する。本文を下記フォーマットに揃え、`closes #<issue番号>` を含めることだけ行う。

## push 前チェック

1 つでも該当すれば対応してから進む：

- [ ] `git status --short` に一時ファイル・生成物・ログ・個人設定が含まれていない
  - 含まれていれば `.gitignore` を確認・修正し、`git rm --cached <path>` で追跡から外す
- [ ] `git log origin/main..HEAD --stat` にこの Issue と無関係な変更（他 Issue の修正・無関係なリファクタ）が混ざっていない
  - 混ざっていれば `git reset --soft <正しい基点>` で巻き戻して staging を整理し直す
- [ ] `git fetch origin main` のあと `git rev-list --count HEAD..origin/main` が 0 である（並行して進めた兄弟 Issue の PR が先にマージされていると、ここで遅れている）
  - 0 でなければ `git merge origin/main` で取り込み、コンフリクトがあれば解消してから次の項目へ（Phase 2「古い main 派生の検知」と同じ手順）
  - 取り込む前に、この PR が触ったファイルに `main` で入った変更を読む（`git log -p HEAD..origin/main -- $(git diff --name-only origin/main...HEAD)`）。作業中に並行してマージされた関連 Issue が、同じ関数に同じ目的の処理を入れていたり、前提を変えていたりすることがある。両方を残すと処理が二重に走る種類の食い違いは、テキストのコンフリクトが無くても（呼び出し側の数行だけでも）起き、既存のテストでは見つからない。重複や食い違いがあれば、どちらに寄せるかを決めてから取り込む（設計が変わるなら Phase 5「実装」手順 1 と同じ扱い）
- [ ] テスト・リントが最新のコミットで通っている（Phase 6 の手順 1 以降に変更があれば再実行。`origin/main` を取り込んだ場合も再実行）

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

   - PR を作ったあとにしかできない DoD（リポジトリの外の設定への反映と、その一致の確認など）が残るなら、`## テスト` にその項目と「マージ前に終える」を書く。マージのあとでないとできない作業なら、`closes` ではなく `refs #<issue番号>` にし、終わってから手でクローズする（`closes` だとマージの時点で Issue が閉じ、残りの DoD と Phase 8 の記録がクローズ後になる）
   - レビューを待たせずに先に見せたい場合は draft で作成し、Phase 8 の記録が終わったら ready にする
   - 作成がタイムアウトや 5xx で失敗扱いになっても、PR 自体は作成されていることがある。**再実行する前に** `search_pull_requests`（query に `head:<ブランチ名>`、`owner` / `repo` を指定）か `gh pr list --head <ブランチ名> --state all` で作成有無を確認し、作成済みならその URL で手順 3 に進む（同一ブランチから重複 PR を作らない）
   - CI（`validate-conventions.yml`）がブランチ名とコミットメッセージを再検証する。赤くなったら規約に合わせて直す

3. 作成された PR の URL をユーザーに返す

## ワークフロー改善余地のメモ（Phase 8 向け）

PR 作成フロー自体への気づき（`closes #N` の付け忘れ誘因、push 周りのハマりどころ、本文テンプレートに足したい項目など）があれば短文メモで控え、Phase 8 で知見ボードに書く。
