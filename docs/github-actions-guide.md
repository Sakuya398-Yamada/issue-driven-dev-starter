# GitHub Actions（CI）解説ガイド

Copilot 版テンプレートに含まれる CI ワークフロー `validate-conventions.yml` を題材に、GitHub Actions の基本構造と読み方・カスタマイズ方法を解説する。GitHub Actions に馴染みがない人向け。

ローカル側のガードレール（git hooks）については [git-hooks-guide.md](git-hooks-guide.md) を参照。

## GitHub Actions とは

GitHub が提供する CI/CD サービス。**リポジトリ直下の `.github/workflows/` に YAML ファイルを置くだけで有効になる**（管理画面での登録などは不要）。1 ファイル = 1 ワークフローで、指定したイベント（PR作成、push 等）が起きると GitHub が使い捨ての仮想マシンを立ち上げ、YAML に書いた処理を実行する。

> **注意**: このスターターリポジトリでは `template-copilot/.github/workflows/` 配下にあるため**動かない**。GitHub Actions が認識するのはリポジトリ直下の `.github/workflows/` だけ。クイックスタートの手順どおり実プロジェクトのルートにコピーすると `.github/workflows/validate-conventions.yml` に配置され、その時点から自動実行される。

## ワークフローYAMLの基本構造

どのワークフローも骨格は同じ3層構造：

```yaml
name: ワークフロー名        # Actionsタブ・PRのチェック欄に表示される

on:                        # ① トリガー: いつ動くか
  ...

jobs:                      # ② ジョブ: 何をするか（複数書くと並列実行）
  ジョブ名:
    runs-on: ubuntu-latest # 実行環境（GitHubが用意するVM）
    steps:                 # ③ ステップ: ジョブ内で順番に実行される処理
      - ...
```

### ① `on:` — トリガー

`validate-conventions.yml` では：

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

- `opened`: PRが作成されたとき
- `synchronize`: PRのブランチに新しいコミットがpushされたとき
- `reopened`: クローズされたPRが再オープンされたとき

つまり「PRが作られたら検証し、修正がpushされるたびに再検証する」という動き。他によく使うトリガーには `push:`（ブランチへのpush時）、`schedule:`（cron定期実行）、`workflow_dispatch:`（手動実行ボタン）がある。

### ② `jobs:` — ジョブ

`validate-conventions.yml` には `branch-name` と `commit-messages` の2ジョブがあり、**それぞれ別のVMで並列に実行される**。片方が失敗してももう片方は最後まで走るので、ブランチ名とコミットメッセージの違反を一度に両方知ることができる。

### ③ `steps:` — ステップ

ステップには2種類ある：

| 書き方 | 意味 | 例 |
|--------|------|----|
| `uses:` | 公開されている既製のアクションを呼び出す | `uses: actions/checkout@v4`（リポジトリをVMにcloneする定番アクション） |
| `run:` | シェルスクリプトをそのまま実行する | `run: git log ...` |

`run:` の中身は**ただの bash** なので、シェルスクリプトが読めればワークフローの大半は読める。

## `validate-conventions.yml` の読み方

### ジョブ1: branch-name（ブランチ名の検証）

```yaml
  branch-name:
    runs-on: ubuntu-latest
    steps:
      - name: Validate branch name
        env:
          BRANCH: ${{ github.head_ref }}   # PRの元ブランチ名を環境変数に渡す
        run: |
          case "$BRANCH" in
            copilot/*|claude/*|main|master|develop)
              echo "Branch '$BRANCH' is exempt."
              exit 0                        # 免除ブランチは即成功
              ;;
          esac
          if ! printf '%s' "$BRANCH" | grep -Eq '^(feature|fix|refactor|docs)/#[0-9]+-.+'; then
            echo "::error::Branch name '$BRANCH' violates ..."
            exit 1                          # exit 1 = ジョブ失敗 = PRに赤い×
          fi
```

ポイント：

- **`${{ github.xxx }}`** は GitHub が提供するコンテキスト変数。`github.head_ref` はPRの元ブランチ名。YAML内の式をシェルに直接埋め込むとインジェクションの危険があるため、**一旦 `env:` で環境変数に落としてから使う**のが安全な書き方
- **`grep -Eq '<正規表現>'`** で規約チェック。`-E` は拡張正規表現、`-q` は出力を抑えて終了コードだけ返すモード。ローカルの git hooks（`.githooks/pre-push`）と**同じ正規表現**を使っている
- **`echo "::error::メッセージ"`** は GitHub Actions の特殊記法（ワークフローコマンド）。ログ上で赤く強調され、PRの「Files changed」やチェック結果にアノテーションとして表示される
- **`exit 1` でジョブが失敗**し、PRのチェック欄に ×が付く。`exit 0`（または最後まで正常実行）なら ✓

### ジョブ2: commit-messages（コミットメッセージの検証）

```yaml
  commit-messages:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0        # 全履歴を取得（デフォルトは最新1コミットのみ）
      - name: Validate commit messages
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}   # PRのマージ先の先端
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}   # PRブランチの先端
          BRANCH: ${{ github.head_ref }}
        run: |
          ...
          git log --no-merges --format='%h %s' "$BASE_SHA".."$HEAD_SHA"
```

ポイント：

- こちらのジョブは `git log` を使うため、最初に **`actions/checkout@v4` でリポジトリをVMにcloneする必要がある**（branch-nameジョブはブランチ名の文字列だけ見るのでclone不要 → checkoutステップが無い）
- **`fetch-depth: 0`** が重要。デフォルトのcheckoutは最新1コミットしか取らない「浅いclone」なので、`BASE_SHA..HEAD_SHA` の範囲を辿れずに `git log` が失敗する。`0` = 全履歴取得
- **`BASE_SHA..HEAD_SHA`** は「PRに含まれるコミットだけ」を列挙する範囲指定。`--no-merges` でマージコミットを免除している（ローカルhooksの `Merge *` 免除と対応）
- あとはコミット件名を1行ずつ `grep -Eq` で検証するループ。`copilot/*` / `claude/*` ブランチでは Issue 番号チェックを緩和する `issue_optional` 判定も、ローカルhooksと同じロジック

## 失敗したときにどう見えるか

1. PRページ下部のチェック欄に `validate-conventions / branch-name` `validate-conventions / commit-messages` が並び、失敗したジョブに ×が付く
2. ×の「Details」をクリックすると Actions のログ画面に飛び、`::error::` で出したメッセージが赤字で表示される
3. 修正をpushすると（`synchronize` トリガーで）自動的に再検証される

## よくあるカスタマイズ

### type を増やす

コミットtype に `perf` を足すなら、`commit-messages` ジョブの正規表現を：

```
^(feat|fix|refactor|test|docs|chore|style): .+
      ↓
^(feat|fix|refactor|test|docs|chore|style|perf): .+
```

**同じ規約が `.githooks/commit-msg` と `git-conventions.instructions.md` にもあるので、必ず3箇所（＋ブランチ側なら `pre-push` も）を揃えること**（同期箇所の一覧は [quickstart-copilot.md](quickstart-copilot.md) のカスタマイズ節参照）。

### チェックを「マージ必須」にする

ワークフローを置いただけでは「×が付いても無視してマージできる」状態。違反PRのマージを機械的に禁止するには、リポジトリの **Settings → Branches → Branch protection rules** で `main` に対して *Require status checks to pass before merging* を有効にし、`branch-name` と `commit-messages` を必須チェックに指定する。

### 検証ジョブを足す

テスト実行やリントも同じ要領でジョブを足せる：

```yaml
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm test
```

## デバッグのコツ

- **Actionsタブ**（リポジトリ上部）に全実行履歴が残る。ジョブ→ステップ単位でログを展開できる
- YAML の構文エラーはワークフロー自体が実行されず、Actionsタブにエラーとして出る。push前に手元で `python3 -c "import yaml; yaml.safe_load(open('...yml'))"` などで構文チェックしておくと早い
- `run:` の中身はただのbashなので、**スクリプト部分だけ手元のターミナルに貼って動作確認できる**（`BRANCH=feature/#1-test` のように環境変数を手で設定して再現する）
- ステップに `run: env | sort` や `echo "$BRANCH"` を一時的に足して、コンテキスト変数に何が入っているか確認するのも定番

## もっと学ぶには

- [GitHub Actions 公式ドキュメント](https://docs.github.com/ja/actions)（日本語あり）
- [ワークフロー構文リファレンス](https://docs.github.com/ja/actions/reference/workflow-syntax-for-github-actions)
- [コンテキスト（`${{ github.xxx }}` の一覧）](https://docs.github.com/ja/actions/reference/contexts-reference)
