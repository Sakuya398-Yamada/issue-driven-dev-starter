---
applyTo: "**"
description: "ワークフロー改善の知見ボード運用規約"
---

# ワークフロー改善の知見ボード

`/issue-start` セッションで得た **ワークフロー改善の気づき** を累積する専用Issueの運用規約と、テンプレート元との双方向のやり取り（**知見の還元** と **テンプレート更新の取り込み**）の規約。

## 知見ボードIssue

- **Issue番号**: #<知見ボードIssue番号> <!-- TODO: セットアップ時に番号を記入 -->
- **タイトル**: `meta: ワークフロー改善の知見ボード`
- **ラベル**: `meta`
- **運用**: 常時Open（クローズしない）

## テンプレート元の情報

このプロジェクトのワークフロー（`.github/copilot-instructions.md` / `.github/instructions/` / `.github/skills/` / `.github/agents/` / `.github/hooks/` / `.githooks/`）は [issue-driven-dev-starter](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter) のテンプレートから生成されている。テンプレート元との接点は `.github/template-version` に集約してある。

- **`.github/template-version`**: `repo=<owner/repo>`（テンプレート元）と `version=vX.Y.Z`（このプロジェクトが取り込んでいる版。テンプレート元の Release タグと同一書式）
- **使用テンプレート**: Copilot 版（`template-copilot/`）
- `/issue-start` の Phase 1 手順 0.5 で `repo` の最新リリースタグと `version` を比較する（後述「テンプレート更新の取り込み」）
- フォークした独自テンプレートを使う場合は `repo` を書き換える

## 何を書くか

ワークフロー全体（`/issue-start` / `/issue-plan` の手順、`.github/instructions/*`、`copilot-instructions.md`、skills、agents、hooks、CI、MCP 運用等）への気づきを集約する。

| 集約対象 | 集約対象外 |
|---------|-----------|
| ワークフローの冗長・曖昧さ | 個別Issueの実装メモ（→ 当該Issueのコメント） |
| スキル定義（SKILL.md / phases）・agents の改善余地 | アプリ仕様そのもの（→ 該当Issueや新規Issue） |
| 規約・ガードレール追加候補 | コード上の個別バグ（→ 別Issueとして起票） |
| MCP / gh CLI 運用のハマりどころ | コードスタイルの好み |

## いつ書くか

`/issue-start` **Phase 8 の最後**（個別Issueへの実装メモ記録が終わった後）に、その回のセッションで見つけた気づきがあれば書き込む。

- **気づきが無い場合はスキップしてよい**（「特になし」と明示コメントしなくてよい）
- **ユーザー確認を挟んでから書き込む**（無人書き込みはしない）

## 記入フォーマット

コメント本文は以下のテンプレートに従う。

```markdown
## ワークフロー改善余地 [#<作業Issue番号>]
**発生Phase**: Phase N（例: Phase 5 実装中）

**気づき**: 何が非効率だった／躓いた／改善の余地があったか

**現状の動作**: 現在のワークフローではどう進んだか

**改善案**: どう変えると良いか（skills / instructions / agents / hooks / CI のどこを変える想定か）

**重要度**: Low / Medium / High

**還元先**: プロジェクト固有 / テンプレート汎用（未還元）
```

`**還元先**` は後述「テンプレート元への還元」の判定結果を書く。テンプレート元へ Issue として還元したら `テンプレート汎用（↗ 還元済み: <テンプレート元Issue URL>）` に編集する。

## 重要度の判定基準

| 重要度 | 目安 |
|--------|------|
| **High** | 毎セッション再発する／セッション失敗の直接原因／ガードレール追加で即座に解消できる |
| **Medium** | 数回に一度発生する／手順が冗長・曖昧で毎回判断コストが掛かる |
| **Low** | 1回限りの気づき／将来あると便利レベル／ユーザー影響が軽微 |

## セッション中の気づきの控え方

Phase 5（実装）〜 Phase 7（PR作成）で「これは後で知見ボードに書くべきかも」と思った事柄は、**その場で直さず短文メモに留める**。Phase 8 で棚卸しし、ユーザー確認を挟んで書き込む。

メモ項目の例：
- どのPhaseで発生したか
- 何が非効率／躓き／改善余地だったか
- 一次情報として残しておきたい再現条件（ツール名、プロンプト文、エラー文等）

## テンプレート元への還元（upstream feedback）

知見ボードに書いた気づきのうち **テンプレート汎用のもの** は、このプロジェクト内で閉じさせず、**テンプレート元リポジトリの Issue として起票**する。テンプレート側はその Issue を通常の `/issue-start` フローで精査・反映し、リリースを切る。リリースは後述の更新チェックでこのプロジェクトにも戻ってくる。

### 還元する / しないの判定

| テンプレート汎用（還元する） | プロジェクト固有（還元しない） |
|---------------------------|----------------------------|
| `/issue-start` の手順・Phase 構成・ユーザー確認の粒度 | `tech-stack.instructions.md` / `coding-standards.instructions.md` の中身 |
| `git-conventions` / `workflow-feedback` / `documentation-policy` の規約そのもの | プロジェクト固有の MCP 構成・VS Code 設定 |
| hooks（preToolUse / git hooks）/ CI（`validate-conventions.yml`）/ agents の挙動・判定ロジック・出力上限 | 特定言語・フレームワークに閉じたハマりどころ（「言語別の例が欲しい」のように一般化できる要望は汎用） |
| Issueテンプレート・セットアップ手順・プレースホルダーの不備 | チーム運用の都合による独自ルール |

迷ったら「**テンプレートを新規に使う別プロジェクトでも同じ問題が起きるか**」で判定する。起きるなら汎用。

### 還元フロー

1. **タイミング**: Phase 8 で知見ボードへの追記が承認・投稿された直後
2. **抽象化**: プロジェクト固有情報を取り除き、ワークフロー手順のレベルに書き直す（後述「還元 Issue に含めないもの」）
3. **重複チェック**: GitHub MCP の `search_issues` を `owner` / `repo` に **テンプレート元** を指定して呼ぶ（または `gh issue list -R <owner/repo> --search "<キーワード>"`）。近いものがあればリンクを提示し、新規起票ではなくそこへのコメント追記を提案する
4. **ユーザー確認**: 抽象化後の本文を提示し Y/E/N を得る。**無人還元はしない**
5. **起票**: GitHub MCP の `issue_write`（method: `create`）の `owner` / `repo` をテンプレート元にして呼ぶか、`gh issue create -R <owner/repo> --title "feedback: <要約>" --label feedback --body-file <tmp>` で起票する（ラベルを付ける権限が無ければ `--label` を外す）。本文に `#N` を書くとテンプレート元の Issue として解釈されるので、還元元の Issue 番号は書かないか `owner/repo#N` 形式にする
6. **起票に失敗した場合**（権限無し・ネットワーク等）: 整形済み本文をユーザーに提示し、テンプレート元の Issue テンプレート「テンプレートへの知見還元」からの手動起票を案内する。フロー全体は止めない
7. **ローカル側への印**: 起票後、このプロジェクトの知見ボードの元コメントの `**還元先**` を `テンプレート汎用（↗ 還元済み: <テンプレート元Issue URL>）` に編集する（`gh api` / 手動）

### 還元 Issue のフォーマット

テンプレート元の Issue テンプレート `.github/ISSUE_TEMPLATE/template-feedback.md` と同じ構成にする。

```markdown
## 還元元

- **プロジェクト**: <owner/repo>（非公開なら「非公開プロジェクト」）
- **使用テンプレート**: Copilot 版（`template-copilot/`）
- **テンプレート版**: vX.Y.Z（`.github/template-version` の `version`）

## 気づき

何が非効率だった／躓いた／改善の余地があったか（プロジェクト固有情報を除いた形で）

## 現状のテンプレートの動作

テンプレートの現在の手順・規約ではどう進むか

## 改善案

- 対象ファイル: `template-copilot/.github/skills/issue-start/phases/05-implementation.md` 等
- 変更内容: どう変えるか

## 重要度

Low / Medium / High（判定基準は上記と同じ）
```

### 還元 Issue に含めないもの

テンプレート元は **公開リポジトリ** である。以下は書かず、ワークフロー手順のレベルに抽象化する：

- プロジェクトのコード断片・ファイルパス・内部識別子・URL
- 顧客名・社内システム名・人名
- 認証情報・環境変数の値
- 非公開プロジェクトの場合はリポジトリ名も省略し「非公開プロジェクト」と書く

## テンプレート更新の取り込み（update check）

Claude Code 版と違い自動のバナーは出さず、`/issue-start` の Phase 1 手順 0.5 で最新リリースタグを取得して `.github/template-version` の `version` と比較する。

```bash
git ls-remote --tags --refs --sort=-v:refname https://github.com/<owner/repo>.git 'v*' | head -n 1 | awk -F/ '{print $NF}'
```

### 差があったときの動き

1. **そのセッションで一度だけ** ユーザーに「更新用 Issue を起票するか」を聞く。一致していれば何も言わない。取得に失敗（オフライン等）したらスキップする
2. **作業中の Issue のブランチでテンプレートを直接更新しない**（1 Issue = 1 PR）。承認された場合の動作は「このプロジェクトに更新用 Issue を起票する」までで、現在の Issue の作業はそのまま続ける
3. 起票前に `search_issues`（`owner` / `repo` にこのプロジェクト）または `gh issue list --search "テンプレートを vX.Y.Z に更新"` で同じ版の更新 Issue が既に無いか確認する
4. 更新用 Issue の内容：
   - タイトル: `refactor: テンプレートを vX.Y.Z に更新`
   - ラベル: `refactor`
   - 本文: 現在の版 → 最新版、Release notes の URL（`https://github.com/<repo>/releases/tag/vX.Y.Z`）、差分の URL（`https://github.com/<repo>/compare/vOLD...vNEW`）、完了条件（下記「取り込み手順」のチェックリスト）
5. ユーザーが「今回はスキップ」を選んだら、そのセッション中は再度聞かない

### 取り込み手順（更新用 Issue を `/issue-start` したとき）

Phase 5 の実装内容は以下。テンプレートのファイルはこのプロジェクト側でカスタマイズ済みなので、**機械的に上書きしない**。

1. Release notes と差分（`git diff vOLD..vNEW -- template-copilot/` をテンプレート元のクローンで実行、または compare URL）を読み、変更ファイルの一覧を得る
2. 変更ファイルごとに、このプロジェクト側の対応ファイル（`template-copilot/` を除いたパス）へ **3-way マージ**（`git merge-file`）で反映する。差分を読んで手で当てるより取りこぼしが少なく、テンプレート側の変更は自動で当たり、プロジェクト固有の記述とぶつかる箇所だけがコンフリクトとして残る（後述「3-way マージの定型手順」）
   - コンフリクト箇所は、テンプレート側の変更を取り込みつつプロジェクト固有の記述を残す形に手で直す。とくにカスタマイズ済みファイル（`tech-stack` / `coding-standards` / `copilot-instructions.md` のプロジェクト固有部分等）は固有の記述を壊さない
   - Release notes に「手動対応」が書かれていればそれに従う
3. `.github/template-version` の `version` を新しい版に更新する
4. 完了条件（更新用 Issue の DoD）:
   - [ ] Release notes の変更ファイルをすべて確認した
   - [ ] カスタマイズ済みファイルのプロジェクト固有記述が失われていない
   - [ ] `.github/template-version` の `version` を更新した

### 3-way マージの定型手順

`<repo>` は `.github/template-version` の `repo`、`vOLD` / `vNEW` は取り込み前後の版。作業ファイルはプロジェクトの外（scratchpad 等）に置く。

```bash
SRC=<scratchpad>/template-src   # テンプレート元のクローン
W=<scratchpad>/template-merge   # 作業ディレクトリ
git clone -q https://github.com/<repo>.git "$SRC"

git -C "$SRC" diff --name-only vOLD vNEW -- template-copilot/ | while read -r t; do
  p=${t#template-copilot/}  # プロジェクト側のパス
  mkdir -p "$W/$(dirname "$p")"
  git show "HEAD:$p"               >"$W/$p.ours"   2>/dev/null || { echo "project にない:  $p"; continue; }
  git -C "$SRC" show "vOLD:$t"     >"$W/$p.base"   2>/dev/null || { echo "vNEW で追加:    $p"; continue; }
  git -C "$SRC" show "vNEW:$t"     >"$W/$p.theirs" 2>/dev/null || { echo "vNEW で削除:    $p"; continue; }
  git merge-file -p -L ours -L vOLD -L vNEW "$W/$p.ours" "$W/$p.base" "$W/$p.theirs" >"$W/$p.merged"
  echo "conflicts=$?  $p"  # 0 ならそのまま使える
done
```

1. `conflicts=0` のファイルは `$W/<path>.merged` をそのままプロジェクト側に書き戻す
2. `conflicts=N`（N > 0）のファイルは `<<<<<<< ours` 〜 `>>>>>>> vNEW` の箇所だけを上記の方針で解消してから書き戻す。マーカーが残っていないことを `grep -n '^<<<<<<<\|^>>>>>>>' <file>` で確かめる
3. ループが `continue` で飛ばしたファイルは手で判断する
   - **project にない / vNEW で追加**: 新規ファイルとして `vNEW` の内容を置く（プロジェクトで意図的に削除していたなら置かない）
   - **vNEW で削除**: プロジェクト側でも削除してよいか確認してから削除する
4. **「現プロジェクト版」は作業ツリーではなく `git show HEAD:<path>` から取る**。Windows で `core.autocrlf=true` だと作業ツリーのファイルは CRLF になっていて、LF のテンプレート側と全行が衝突する。`HEAD` の内容（リポジトリ内の LF）を使えば改行コードの差は出ない。このため取り込み作業は未コミットの変更が無い状態で始める

## 棚卸し運用（ユーザー側）

コメントが溜まってきたら、ユーザーが手動で以下を行う：

1. 独立した改善Issue として起票する（通常の Issue ラベル: `feature` / `refactor` / `docs` 等を付与）
2. 知見ボードIssueの元コメントを編集し、末尾に以下を追記する
   ```
   ✅ Issue #<昇格先Issue番号> で対応
   ```
3. 昇格後のIssueは通常の `/issue-start` フローで実装する
4. 実装した改善が **テンプレート汎用** で、まだ還元していなければ、上記「還元フロー」でテンプレート元にも Issue を起票する（Phase 8 で還元済みなら不要）

これにより、どの知見が回収済み・還元済みかを一目で追跡できる。

## 自動化しないこと

- **無人コメント投稿はしない**: ユーザー確認（Y/E/N）を挟む
- **テンプレート元への無人起票はしない**: ローカル知見ボードへの承認とは別に、還元用に抽象化した本文で改めて確認を取る
- **テンプレートの無人更新はしない**: 更新チェックは「通知して更新用 Issue の起票を提案する」までで、ファイルの書き換えは更新用 Issue の `/issue-start` で行う
- **知見ボードIssueを自動クローズしない**: 常時Open運用
- **過去セッションからの遡及集約は行わない**: 未来のセッションから運用する
