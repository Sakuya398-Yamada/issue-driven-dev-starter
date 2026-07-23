# git hooks 解説ガイド

Copilot 版テンプレートに含まれるローカルガードレール `.githooks/`（`commit-msg` / `pre-push`）を題材に、git hooks の仕組みと読み方・カスタマイズ方法を解説する。git hooks に馴染みがない人向け。

CI 側のガードレール（GitHub Actions）については [github-actions-guide.md](github-actions-guide.md) を参照。

## git hooks とは

git 本体に組み込まれている仕組みで、**コミットやpushなどの操作の前後に、決まった名前のスクリプトを自動実行する**。スクリプトが 0 以外の終了コードを返すと、その操作自体が中止される。これを使って「規約違反のコミットはそもそも作らせない」を機械的に強制できる。

CI（GitHub Actions）との違いは実行タイミング：

| | git hooks | CI |
|---|---|---|
| 実行場所 | 各開発者のローカルマシン | GitHub のサーバー |
| タイミング | コミット/pushの**瞬間** | PRを作った/更新した**後** |
| フィードバック | 即座（違反コミットが作られない） | push後に×が付く（コミットは既に存在） |
| バイパス | `--no-verify` で可能 | Branch protection を設定すれば不可 |

このテンプレートでは**両方を同じ規約で二重に**設定している。hooks が第一防衛線（即座に止める）、CI が最終防衛線（hooks 未設定の環境や Copilot coding agent を拾う）。

## 主なフックの種類

フックはスクリプトのファイル名で役割が決まる。よく使うもの：

| フック名 | いつ動くか | 中止できる操作 | 主な用途 |
|---------|-----------|--------------|---------|
| `pre-commit` | `git commit` の直前（メッセージ入力前） | コミット | リント・フォーマットチェック |
| `commit-msg` | コミットメッセージ確定直後 | コミット | **メッセージ規約の検証**（このテンプレートで使用） |
| `pre-push` | `git push` の直前 | push | **ブランチ名検証**（このテンプレートで使用）、テスト実行 |
| `post-checkout` | ブランチ切り替え後 | （中止不可、通知用） | 依存関係の再インストール促し |

## `core.hooksPath` — なぜ `.githooks/` ディレクトリなのか

git のデフォルトでは、フックは `.git/hooks/` に置く。しかし **`.git/` 配下はコミットできない**ため、そのままではチームに配布できない（各自が手でコピーする運用になり、確実に形骸化する）。

そこでこのテンプレートでは：

1. フックを通常のディレクトリ **`.githooks/`** に置いてリポジトリにコミットする
2. 各開発者が以下を1回実行して、git のフック参照先を差し替える：

   ```bash
   git config core.hooksPath .githooks
   ```

これで `git commit` / `git push` のたびに `.githooks/` 内のスクリプトが実行されるようになる。

> **重要な注意点**
> - `core.hooksPath` は**リポジトリローカル設定**（`.git/config` に書かれる）なので、**クローンした人それぞれが個別に実行する必要がある**。README やオンボーディング手順に含めておくこと
> - スクリプトには**実行権限が必要**（`chmod +x .githooks/*`）。git は実行ビットを保存するので、一度権限付きでコミットされていれば通常は不要だが、zipダウンロード等で取得した場合は落ちることがある
> - Windows では **Git Bash 環境で動く**（フックは bash スクリプトのため。Git for Windows を入れていれば通常そのまま動く）

## `.githooks/commit-msg` の読み方

`commit-msg` フックは、**引数 `$1` にコミットメッセージが書かれた一時ファイルのパス**を受け取る。

```bash
msg_file="$1"
first_line=$(head -n 1 "$msg_file")   # 検証するのは1行目（件名）だけ
```

その後の流れ：

1. **git が自動生成するメッセージは免除**：

   ```bash
   case "$first_line" in
     Merge\ *|Revert\ *|fixup!\ *|squash!\ *)
       exit 0
       ;;
   esac
   ```

   マージコミット（`Merge branch ...`）等は人間が件名を書くものではないので、規約チェックの対象外にする。

2. **現在のブランチを見て Issue 番号要否を判定**：

   ```bash
   current_branch=$(git rev-parse --abbrev-ref HEAD ...)
   case "$current_branch" in
     copilot/*|claude/*) issue_optional=1 ;;
   esac
   ```

   エージェントのセッションブランチ上では Issue 番号を省略可にしている（規約どおり）。

3. **type プレフィックスの検証**（常に必須）：

   ```bash
   if ! printf '%s' "$first_line" | grep -Eq '^(feat|fix|refactor|test|docs|chore|style): .+'; then
     cat >&2 <<EOF        # >&2 = エラーメッセージを標準エラー出力へ
   [hook:commit-msg] ...違反内容と期待フォーマットの説明...
   EOF
     exit 1               # ← 0以外で終了するとコミットが中止される
   fi
   ```

4. **Issue 番号の検証**（セッションブランチ以外で必須）。ロジックは同様。

すべて通れば `exit 0` でコミットが成立する。

## `.githooks/pre-push` の読み方

`pre-push` フックは引数ではなく、**標準入力から「何をpushしようとしているか」を受け取る**。1行が1つのref（ブランチやタグ）で、フォーマットは：

```
<ローカルref> <ローカルSHA> <リモートref> <リモートSHA>
```

そのため全体が `while read` ループになっている：

```bash
while read -r _local_ref _local_sha remote_ref _remote_sha; do
  case "$remote_ref" in
    refs/heads/*) branch="${remote_ref#refs/heads/}" ;;   # refs/heads/feature/#1-x → feature/#1-x
    *) continue ;;                                        # タグ等はスキップ
  esac

  case "$branch" in
    copilot/*|claude/*|main|master|develop)
      continue          # 免除ブランチ
      ;;
  esac

  if ! printf '%s' "$branch" | grep -Eq '^(feature|fix|refactor|docs)/#[0-9]+-.+'; then
    ...エラーメッセージ...
    status=1            # 即exitせず全refを検証してからまとめて失敗させる
  fi
done

exit "$status"
```

ポイント：

- `git push origin A B` のように複数ブランチを同時にpushできるため、ループで全件検証する
- 変数名の先頭 `_`（`_local_ref` 等）は「読み取るが使わない」ことを示す慣習
- ブランチ名の検証に `pre-push` を使っているのは、**git にはブランチ作成そのものを止めるフックが無い**ため。ローカルで好きな名前のブランチを作ることはできるが、規約違反の名前ではpushできない、という設計（Claude Code 版はツール実行前フックがあるので `git checkout -b` の時点で止められる。後述）

## 動作確認

セットアップ後、わざと違反してみると動きが分かる：

```bash
# commit-msg: ブロックされる
git commit --allow-empty -m "test"
# → [hook:commit-msg] Commit message violates the project convention. ...

# commit-msg: 通る
git commit --allow-empty -m "chore: 動作確認 #1"

# pre-push: ブロックされる
git checkout -b test-branch
git push -u origin test-branch
# → [hook:pre-push] Branch name 'test-branch' violates the project convention. ...
```

## 制約と割り切り

- **`--no-verify` でバイパスできる**: `git commit --no-verify` / `git push --no-verify` はフックを飛ばす。git hooks はあくまでクライアントサイドの仕組みで、悪意には対抗できない。規約上バイパス禁止とした上で、CI ＋ Branch protection を最終防衛線にする
- **ローカルの git 操作にしか効かない**: GitHub の Web UI 上での編集や、Copilot coding agent（クラウド実行）のコミットには効かない → これも CI が拾う
- **`core.hooksPath` を設定し忘れた人には効かない** → 同上

## Claude Code 版の hooks との違い

Claude 版テンプレート（`template/.claude/hooks/`）は git hooks ではなく、**Claude Code の PreToolUse hook**（ツール実行前フック）を使っている。似て非なるものなので整理しておく：

| | Claude 版（PreToolUse hook） | Copilot 版（git hooks） |
|---|---|---|
| 仕組み | Claude Code がツール（Bash等）を実行する直前にスクリプトを挟む | git がコミット/push の直前にスクリプトを実行する |
| 誰に効くか | **Claude Code のツール呼び出しのみ**（人間のターミナル操作には効かない） | **ローカルのgit操作すべて**（人間にもAIにも効く） |
| ブランチ作成 | `git checkout -b` の時点でブロックできる | 作成は止められず、push時にブロック |
| ブロック方法 | exit 2 | exit 非0 |
| 入力の受け取り | stdin の JSON（実行されようとしているコマンド） | フック種別ごとの規定（引数 or stdin） |
| 設定場所 | `.claude/settings.json` に登録 | `git config core.hooksPath .githooks` |

Copilot にはツール実行前フックに相当する仕組みが無いため、git 標準の hooks で近い効果を実現している、という関係。

## よくあるカスタマイズ

### type を増やす

`commit-msg` / `pre-push` 内の正規表現を編集する。**同じ規約が CI（`validate-conventions.yml`）と規約文書（`git-conventions.instructions.md`）にもあるので必ず全箇所を揃えること**（同期箇所の一覧は [quickstart-copilot.md](quickstart-copilot.md) のカスタマイズ節参照）。

### フックを足す

`.githooks/` に規定の名前でスクリプトを置いて `chmod +x` するだけ。例えば push 前にテストを走らせるなら：

```bash
#!/usr/bin/env bash
# .githooks/pre-push に追記（または pre-push を分割して呼び出し）
npm test || exit 1
```

ただし pre-push は1ファイルしか置けないので、既存のブランチ名検証と共存させる場合は同じファイル内に追記する。

### Issue 番号必須を緩和する

- ブランチ名側: `pre-push` の正規表現から `#[0-9]+-` を外す
- コミット側: `commit-msg` の `issue_optional` 判定を常に `1` にする

いずれも CI 側（`validate-conventions.yml`）にも同じ変更を入れること。

## もっと学ぶには

- [git hooks 公式ドキュメント（githooks(5)）](https://git-scm.com/docs/githooks)（各フックの引数・stdin仕様の一次情報）
- [Pro Git 日本語版 8.3 Git のカスタマイズ - Git フック](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%83%95%E3%83%83%E3%82%AF)
