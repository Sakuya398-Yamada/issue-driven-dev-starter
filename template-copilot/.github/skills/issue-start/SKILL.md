---
name: issue-start
description: GitHub Issue を起点に、ブランチ作成・探索・設計・実装・レビュー・PR作成・Issueへの記録まで一連の開発を行うスキル。「Issue #N をやって」「#N を実装して」「/issue-start #N」のように Issue 番号を指定して作業を依頼されたときに使う。Issue の分割・起票だけなら /issue-plan を使う。各 Phase の詳細は phases/ 配下に分割してあり、該当 Phase に入る直前に読む。
argument-hint: "#<Issue番号>"
---

# Issue開発スキル（/issue-start）

ユーザー入力から Issue 番号を取得する（`#` の有無は問わない。番号が読み取れなければ最初に質問する）。

指定された GitHub Issue に基づいて、ブランチ作成から実装・レビュー・PR作成・Issue への記録までを一連で行う。

## Phase一覧（progressive disclosure）

各 Phase の手順は `phases/` 配下に分割してある。**該当 Phase に入る直前にそのファイルを読む**。冒頭でまとめて読み込まない。

| # | Phase | ファイル | スキップ |
|---|-------|---------|---------|
| 1 | Issue分析・不足確認・補完（+ テンプレート更新チェック） | [phases/01-issue-analysis.md](phases/01-issue-analysis.md) | 不可 |
| 2 | ラベル付与・ブランチ作成 | [phases/02-branch-setup.md](phases/02-branch-setup.md) | 不可 |
| 3 | コード探索 | [phases/03-exploration.md](phases/03-exploration.md) | 修正箇所が明確な bug / docs は可（利用者から見える挙動・上限・制約を変える Issue では、利用者向けドキュメントの Grep だけは行う。扱いは `phases/03-exploration.md`「スキップ条件」） |
| 4 | 設計とユーザー承認 | [phases/04-design.md](phases/04-design.md) | 差分を 1 文で説明できる変更は可（手順書・規約から人の確認を外す・弱める変更は不可） |
| 5 | 実装・検証・コミット | [phases/05-implementation.md](phases/05-implementation.md) | 不可 |
| 6 | コードレビュー | [phases/06-review.md](phases/06-review.md) | 散文のみの docs は可（手順・コマンドを含むランブックは不可） |
| 7 | PR作成 | [phases/07-pr-creation.md](phases/07-pr-creation.md) | 不可 |
| 8 | Issueへの記録（+ 知見ボード・テンプレート元への還元） | [phases/08-issue-recording.md](phases/08-issue-recording.md) | 不可 |

> **リポジトリへの変更が出ない Issue**（「〜を裏取りし、必要なら修正 Issue を起票、不要ならクローズ」のような調査だけの Issue と、Issue 本文の書き換えやマージ済みブランチの削除のような GitHub 上の操作だけで終わる Issue）は、Phase 2〜7 を省略して Phase 8 に進む。調査の結果リポジトリへの変更が出れば、通常どおり Phase 2 から進める。分岐の詳細は `phases/01-issue-analysis.md`「リポジトリへの変更が出ない Issue（調査・GitHub 上の操作だけ）」

## 全体ルール

- **確認ポイント**: Phase 1 の不足確認、Phase 4 の設計承認、スコープ外問題の起票、GitHub 上の操作だけで終わる Issue の適用前（dry-run の結果を示す）、Phase 8 の知見ボード追記とテンプレート元への起票では、ユーザーの Y/E/N を得てから進む。それ以外の場面では進捗を 2〜3 行で共有しながら自律的に進める
- **確認の聞き方**: 確認ポイントと各 Phase の提示フォーマットの問いは、Copilot CLI では `ask_user` ツールで選択式に聞く。1 つのテキストに並べて聞くと、「Y」だけの返事がどれへの答えか読めない
  - 設計案・起票本文などの中身は先にメッセージ本文に出し、質問には問いと選択肢だけを載せる。問いには候補番号とタイトルを入れ、質問だけでどれへの確認か読めるようにする
  - 選択肢はフォーマットの選択肢の行（[Y] / [N]、Phase 1 の旧 PR の [R] / [N] など）から取る。行の無い問い（Phase 4 の案の選択、Phase 1.5 の [Y/E/N]）は、案が複数なら案ごと（推奨を先頭）、1 つなら「進める / 進めない」のように立てる。[E] や修正点は自由記述で受ける。受けたあとの扱いは各フォーマットの [E] の行のとおり
  - 確認が複数あるときは 1 問ずつ分けて聞く。plan mode の承認を設計承認に充てるときは、ほかの確認を先に聞く
  - `ask_user` が使えないとき（`--no-ask-user` 付きの実行、ツールが出ていない環境）は、質問ごとに名前（`設計`・`候補1` など）を付けて並べ、`設計-Y 候補1-N` の形で答えてもらう
- **判断の線引き**: 読み方が分かれて成果物が変わる曖昧さは質問する。調べれば分かること（コードの構造・ライブラリの使い方・既存の挙動）は自分で調べる。ツール呼び出しの回数を理由に止まらない
- **1 Issue = 1 PR**: スコープ外の変更を混ぜない（後述「スコープ外問題の起票提案」）
- **GitHub 操作**: GitHub MCP サーバー（Copilot CLI / cloud agent は組み込み、VS Code は `.vscode/mcp.json` に登録）を使う。未接続・エラー時は `gh` CLI にフォールバックし、それも無ければ整形済みの本文を提示してユーザーに操作を依頼する。フロー全体は止めない
- **規約**: `.github/copilot-instructions.md` と `.github/instructions/*.instructions.md` に従う。ブランチ名・コミットメッセージは preToolUse hook（`.github/hooks/`）・git hooks（`.githooks/`）・CI が機械検証する。拒否されたら `--no-verify` で回避せず、規約に合わせて直す
- **セッション**: 1 セッション 1 Issue。別の Issue に移るときは新しいチャットを開く（Copilot CLI は `/clear`）

## サブエージェント

Phase 3/4/6 で使う専門エージェントは `.github/agents/` にカスタムエージェントとして定義済み：

| エージェント | 役割 | 定義 |
|-------------|------|------|
| `code-explorer` | コード探索・トレース。生の探索ログを主会話に入れず要約だけ受け取る | `.github/agents/code-explorer.agent.md` |
| `code-architect` | 実装ブループリント（1 案に絞って提案） | `.github/agents/code-architect.agent.md` |
| `code-reviewer` | 実装者とは別の新しいコンテキストでの批判的レビュー（信頼度80以上のみ報告） | `.github/agents/code-reviewer.agent.md` |

- **VS Code（エージェントモード）/ Copilot CLI**: カスタムエージェントをサブエージェントとして起動できる（VS Code は `runSubagent` ツール、CLI はエージェントへの委譲）。複数のサブエージェントは並列に走る
- **Copilot cloud agent（github.com で Issue をアサイン）**: サブエージェントは使えない。同一セッション内で観点を切り替えて逐次実行する
- 起動数は各 Phase の起動数表に従う（単純な変更は 1 個、観点が複数あるときだけ 2〜3 個）。サブエージェントはチャット 1 往復の十数倍のトークンを使うので、検索 1 回で済むことには使わない。プロンプトには目的・スコープ・返却フォーマットと上限・除外事項を含める

## MCP ツール

| 用途 | 使うもの | 未接続時のフォールバック |
|------|---------|------------------------|
| Issue / PR 操作 | GitHub MCP: `issue_read` / `issue_write` / `search_issues` / `list_issues` / `sub_issue_write` / `add_issue_comment` / `update_issue_comment` / `pull_request_read` / `search_pull_requests` / `create_pull_request` | `gh issue ...` / `gh pr ...` |
| 外部仕様・技術情報 | `fetch` ツールや Web 検索 | ユーザーに確認 |
| ライブラリの最新ドキュメント | context7 MCP（`resolve-library-id` → `query-docs`）等 | 公式ドキュメントを `fetch` |
| UI 動作確認 | Playwright MCP（`browser_navigate` / `browser_snapshot`。cloud agent では既定で有効） | ユーザーに手動確認を依頼し、未検証と明記する |

<!-- TODO: プロジェクトで実際に接続している MCP サーバーに合わせて上表を編集する -->

## スコープ外問題の起票提案（Phase横断）

当該 Issue のスコープ外の問題を見つけたら **その場で直さず、別 Issue としての起票を提案する**（1 Issue = 1 PR）。

### 検出タイミング

| Phase | 検出場面 | 扱い |
|-------|---------|------|
| 1（Issue 分析） | 乖離チェック・外部情報の裏取りなどで見つけた別の問題 | Phase 1.5「補完結果の確認」の前に、別の問いとして聞く（「全体ルール」の「確認の聞き方」のとおり 1 問ずつ。補完が無ければ、それだけを聞いてから Phase 2 に進む）。起票したうえで親の本文に子の番号を書くなら、その番号を入れた補完案で確認する |
| 3（コード探索） | 既存コードの別バグ・設計上の違和感 | Phase 末尾で一覧化して提示 |
| 5（実装） | 実装中に周辺コードのバグに遭遇 | 即時は記録のみ、Phase 末尾でまとめて提示 |
| 6（レビュー） | レビュアーの指摘が当該 Issue の DoD 外 | スコープ内（即修正）／外（起票候補）に仕分け |

### 起票判定基準

- **起票する**: 機能不具合／仕様乖離／データ誤り／ユーザー体験を損なう振る舞い／複数機能横断の類似問題
- **起票しない**: コードスタイルの好み／影響の無いリファクタ案／当該 Issue の DoD 内／重複が確かな既存 Issue（重複かもしれないだけの候補は、起票フローで [A] を示す）

### 起票フロー（共通）

1. **重複チェック**: GitHub MCP の `search_issues`（`owner` / `repo` を指定、query は自然文）または `gh issue list --search "<キーワード>"` で近い Issue を探す。候補があれば、手順 2 の提示にリンクを載せ、選択肢に [A]（既存 Issue への追記）を足す。書き方のパターンが原因の問題（使えないコマンドの指定・古い参照・同じ誤記など）は、起票の前に同じ書き方をリポジトリ全体で Grep し、当たったうち同じ誤りの箇所を 1 つの候補にまとめる（別の語の一部として当たったものや、CHANGELOG のような履歴の記述は入れない）。同じ書き方は Open Issue の本文からも探す。ガイドや知見から写した完了条件・手順に同じ誤りが残っていることがあり、残したままだと、その Issue を `/issue-start` したときの乖離チェックで 1 件ずつ見つかって手戻りになる。`search_issues` は意味で探すので文字列の一致には使わず、Open Issue を本文ごと一覧で取って文字列で絞る（GitHub MCP の `list_issues`（`state: OPEN`、`fields` に `body`）。`gh` なら `gh api "repos/{owner}/{repo}/issues?state=open&per_page=100" --jq '.[] | select(.pull_request == null) | select((.body // "") | contains("<書き方>")) | [.number, .title] | @tsv'`。100 件を超えるなら `&page=2` 以降も取る）。当たった Issue は手順 2 の提示に載せる。その本文の書き換えは GitHub 上の操作なので、起票とは別に、新旧の差分を示して確認を得てから行う（`phases/01-issue-analysis.md`「GitHub 上の操作だけで終わる Issue」手順 2）。1 か所だけで起票すると、残りの箇所は次にそのファイルを触ったセッションが見つけるたびに、別の Issue に分かれていく。まとめると粒度（`git-conventions.instructions.md`「粒度」）を超えるなら、箇所で分けて起票し、互いを「## 関連Issue」に書く
2. **ユーザー確認**: 以下のフォーマットで提示する

   ```
   【候補N】
   タイトル案: <ラベル名>: <簡潔な説明>
   ラベル: bug / feature / refactor / docs のいずれか
   概要: 何が問題か（1〜3行）
   コード箇所: path/to/file.ts:L10-20（バグの場合）
   再現手順: 箇条書き（バグの場合のみ）
   完了条件: <1〜2 行。何が確認できれば直ったと言えるか>
   依存: なし / #<親番号>（親 Issue のまだマージされていない変更を前提にするとき。手順 3）
   既存Issue重複チェック: なし / 候補 #NN
   同じ書き方が残る Open Issue: なし / #NN（書き方のパターンが原因のときだけ。本文の書き換えは別に確認する）

   起票しますか？
    [Y] そのまま起票
    [E] タイトル/本文を編集して起票
    [A] 既存 Issue #NN にコメントで追記する（重複候補があるときだけ）
    [N] 起票しない（口頭報告のみ）
   ```

   [A] のときは起票せず、その既存 Issue に、見つけた内容（概要・箇所・再現手順）をコメントで追記する
3. **起票**: 承認（Y/E）後、`issue_write`（method: `create`、`parent_issue_number` に親 Issue 番号）または `gh issue create --parent <親番号>`（gh 2.94 以降）で **sub-issue として** 作成する。本文は `.github/ISSUE_TEMPLATE/issue.md` の構成と `git-conventions.instructions.md`「粒度」に揃える。sub-issue にできない場合は本文末尾に `親Issue: #<親番号>` と書く。子 Issue の完了条件が、作業中の親 Issue のまだマージされていない変更を前提にする（親が足す API を使う別の機能など）なら、本文の「## 関連Issue」に `依存: #<親番号>` を書く。書かないと子の PR が親より先にマージされ得る。書いておけば、子を `/issue-start` したときの Phase 1 の依存チェック（依存先が未完了なら着手前に確認）がそのまま拾う。親の変更そのもので誤りになる記述（親が変える仕様を説明している利用者向けドキュメントなど）は、子 Issue にせず、不可避な副次変更として親の PR で直す（`git-conventions.instructions.md`「スコープ原則（1 Issue = 1 PR）」、`phases/03-exploration.md`「スキップ条件」）
4. **親Issueへの記録**: Phase 8 で親 Issue に子 Issue の一覧をコメントする

無人起票はしない。スコープ外問題を自動修正もしない（口頭報告か起票のみ）。cloud agent のように対話できない実行形態では、起票せずに PR 本文の「スコープ外で見つけた問題」節に列挙する。

## ワークフロー改善の知見ボード（Phase 8）

個別 Issue のスコープ外問題（コードのバグ等）とは別に、**ワークフロー自体（`/issue-start` の手順・`.github/instructions/*`・`copilot-instructions.md`・hooks・agents・skills・MCP 運用）への気づき** を累積する常時 Open の Issue がある。

- **知見ボードIssue**: 番号は `.github/instructions/workflow-feedback.instructions.md`「知見ボードIssue」
- **書き込み**: Phase 8 の最後にユーザー確認を挟んで `add_issue_comment`（`gh issue comment`）で追記する
- **Phase 5/6/7 との連携**: 実装・レビュー・PR作成中に気づいた改善余地は短文メモとして控え、Phase 8 で棚卸しする。気づきが無ければスキップしてよい
- **テンプレート元への還元**: 気づきが「テンプレート汎用」（別プロジェクトでも同じ問題が起きるもの）なら、プロジェクト固有情報を除いた上で改めて確認を取り、テンプレート元リポジトリ（`.github/template-version` の `repo`）に Issue として起票する（Phase 8 手順 6）

## 注意事項

- すべてのブランチは `main` から派生し、`main` にマージする
- 作業中の変更がある場合はユーザーに確認してからブランチを切り替える
- 過去の Issue や PR から関連情報を積極的に収集する
- 完了報告は検証結果（テスト・リント・動作確認）を添えて行う。検証できなかった項目は未検証と明記する
