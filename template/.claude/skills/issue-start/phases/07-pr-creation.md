# Phase 7: PR作成

## push 前チェック

1 つでも該当すれば対応してから進む：

- [ ] `git status --short` に一時ファイル・生成物・ログ・個人設定（`.claude/settings.local.json` 等）が含まれていない
  - 含まれていれば `.gitignore` を確認・修正し、`git rm --cached <path>` で追跡から外す
- [ ] `git log origin/main..HEAD --stat` にこの Issue と無関係な変更（他 Issue の修正・無関係なリファクタ）が混ざっていない
  - 混ざっていれば `git reset --soft <正しい基点>` で巻き戻して staging を整理し直す
- [ ] `git fetch origin main` のあと `git rev-list --count HEAD..origin/main` が 0 である（並行して進めた兄弟 Issue の PR が先にマージされていると、ここで遅れている）
  - 0 でなければ `git merge origin/main` で取り込み、コンフリクトがあれば解消してから次の項目へ（Phase 2「古い main 派生の検知」と同じ手順）
- [ ] テスト・リントが最新のコミットで通っている（Phase 6 の手順 1 以降に変更があれば再実行。`origin/main` を取り込んだ場合も再実行）

## 手順

1. リモートにブランチをプッシュする：

   ```bash
   git push -u origin <ブランチ名>
   ```

2. GitHub MCP の `create_pull_request` で `main` への PR を作成する（`.claude/rules/git-conventions.md`「Pull Request」）。`gh pr create --title ... --body-file <tmp>` でも可

   - `owner` / `repo`: リポジトリ情報
   - `title`: `<type>: <説明> #<issue番号>`
   - `head`: 作業ブランチ名 / `base`: `main`
   - `body`:

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

   - レビューを待たせずに先に見せたい場合は `draft: true` で作成し、Phase 8 の記録が終わったら ready にする
   - 作成がタイムアウトや 5xx で失敗扱いになっても、PR 自体は作成されていることがある。**再実行する前に** `search_pull_requests`（query に `head:<ブランチ名>`、`owner` / `repo` を指定）か `gh pr list --head <ブランチ名> --state all` で作成有無を確認し、作成済みならその URL で手順 3 に進む（同一ブランチから重複 PR を作らない）

3. 作成された PR の URL をユーザーに返す

4. PR の auto-fix（CI 失敗とレビューコメントへの修正の自動 push）を始める。前提（リポジトリに Claude GitHub App が入っている、claude.ai のアカウントでクラウドセッションが使える）は Claude からは確かめられないので、確かめずに下の手段を取る。`CLAUDE_CODE_REMOTE` 環境変数で分岐する：

   | `CLAUDE_CODE_REMOTE` | 手段 |
   |---------------------|------|
   | `true`（Claude Code on the web などのクラウドセッション） | PR 監視のツール（`subscribe_pr_activity` 等）があれば、この PR を購読して監視を始める。無ければ CI ステータスバーの **Auto-fix** トグルを ON にするようユーザーに案内する |
   | それ以外（CLI / デスクトップアプリ / IDE 拡張） | 次の 2 つをまとめてユーザーに案内する。CLI なら PR のブランチにいる状態で `/autofix-pr` を実行する（組み込みコマンドなので Claude からは実行できない。`gh` CLI の認証が要り、既定ブランチ上では動かない）。デスクトップアプリなら CI ステータスバーの **Auto-fix CI & address comments** を ON にする |

   - 案内した操作の完了は待たずに Phase 8 に進む。購読ツールが失敗した、またはユーザーが auto-fix を使わないと言ったら、この手順は省略する（フロー全体は止めない）
   - このセッションで購読した場合、届いた CI 失敗やレビュー指摘は Phase 6 と同じ基準で仕分ける。スコープ内だけ直して push し、スコープ外は SKILL.md「スコープ外問題の起票提案」に回す（1 Issue = 1 PR）
   - auto-fix はこのブランチにコミットを push する。以降ローカルから同じブランチに push するときは、先に `git pull` で取り込む
   - auto-fix はベースブランチが進んで起きたコンフリクトには反応しない。コンフリクトは従来どおり人が解消する

## ワークフロー改善余地のメモ（Phase 8 向け）

PR 作成フロー自体への気づき（`closes #N` の付け忘れ誘因、push 周りのハマりどころ、本文テンプレートに足したい項目など）があれば短文メモで控え、Phase 8 で知見ボードに書く。
