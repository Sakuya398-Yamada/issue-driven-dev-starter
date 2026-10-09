# Phase 2: ラベル付与 & ブランチ作成

> **Copilot cloud agent の場合**: ブランチ（`copilot/*`）は cloud agent が自動で作るので、この Phase はラベル付与だけ行う。

## ラベル付与

Issue にラベルが付いていない場合、本文の内容から判定して付与する：

- 新しい機能やデータモデルの追加 → `feature`
- 既存機能の不具合修正 → `bug`
- 動作を変えないコード改善 → `refactor`
- ドキュメントのみの変更 → `docs`
- 判断がつかない場合 → ユーザーに確認

GitHub MCP の `issue_write`（method: `update`、`labels`）または `gh issue edit <N> --add-label <label>` で付与する。

## ラベル → ブランチ prefix

| Issueラベル | ブランチprefix |
|-------------|---------------|
| `feature` | `feature/` |
| `bug` | `fix/` |
| `refactor` | `refactor/` |
| `docs` | `docs/` |

## ブランチ作成

```bash
git checkout main
git pull origin main
git checkout -b <type>/#<issue番号>-<kebab-case説明>
```

- 説明は小文字英数字とハイフンのみ（例: `feature/#42-add-user-model`）。preToolUse hook（`.github/hooks/validate-branch-name.sh`）が作成時に検証し、git の `pre-push` hook と CI（`validate-conventions.yml`）が push / PR 時に再検証する
- 作業中の変更がある場合は、ユーザーに確認してから切り替える

## 古い main 派生の検知

`git pull origin main` を忘れた、別作業から復帰した直後などに、新ブランチが古い main から派生する事故が起きる。テストが失敗するまで気付かないと `stash → fetch → merge → unstash` の手戻りになるので、**最初のコミット前に** 確認する：

```bash
git fetch origin main
git rev-list --count HEAD..origin/main   # 0 より大きければ遅れている
```

### 遅れていた場合

```bash
git stash push -m "issue-start wip"   # 作業中の変更がある場合のみ
git merge origin/main                 # ファストフォワード or 3-way merge
git stash pop                         # stash した場合のみ
```

`git merge origin/main` で `Merge branch 'main' into <branch>` コミットが入るのは正常な挙動で、PR を squash merge する運用なら最終履歴には影響しない。

> 検知だけ自動化し、取り込みは hook で強制しない理由: `git merge` を hook で自動実行すると stash の取り扱いミスや conflict 解消の自動化リスクが大きい。
