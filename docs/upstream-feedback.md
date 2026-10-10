# 知見のテンプレートへの還元とテンプレート更新（upstream feedback / update check）

このテンプレートを使ったプロジェクトで得た **ワークフロー自体への気づき** をテンプレート（このリポジトリ）に戻し、テンプレート側の改善を利用プロジェクトに届けるための仕組みの解説。

## なぜ必要か

テンプレートをコピーした時点で、利用プロジェクトのワークフローはテンプレートから切り離される。利用プロジェクト側の知見ボード（`meta: ワークフロー改善の知見ボード`）に気づきが溜まっても、それはそのプロジェクト内で閉じ、テンプレートには戻ってこない。逆に、テンプレート側を改善しても、既にコピー済みのプロジェクトは気づかない。

そこで 2 つの経路を用意する：

- **還元（利用プロジェクト → テンプレート）**: `/issue-start` Phase 8 で「テンプレート汎用」と判定された気づきを、このリポジトリの **Issue として起票**する
- **更新（テンプレート → 利用プロジェクト）**: テンプレートは **Release（`vX.Y.Z` タグ）** で版を刻む。利用プロジェクト側は `template-version` に取り込み済みの版を持ち、セッション開始時に最新タグと比較して差があれば **更新用 Issue の起票を提案**する

## 全体像

```
利用プロジェクトA                              issue-driven-dev-starter（このリポジトリ）
────────────────                              ──────────────────────────────────
/issue-start #N
  Phase 8 手順5: 知見ボードへ追記
     └ 還元先: プロジェクト固有 ──→ ここで完結
     └ 還元先: テンプレート汎用
  Phase 8 手順6: 抽象化 → ユーザー確認 ────→ Issue「feedback: ...」（label: feedback）
                                                 │
                                                 ▼ 精査（ユーザー）
                                              /issue-start で template/ と
                                              template-copilot/ を修正、version を上げる
                                                 │
                                                 ▼ マージ → Release vX.Y.Z
SessionStart hook: template-version と ◀────────┘
最新タグを比較 → ⚠ update available
  │
  ▼ /issue-start Phase 1 手順0.5（セッションで一度だけ）
  「更新用 Issue を起票しますか？」 → [Y] → Issue「refactor: テンプレートを vX.Y.Z に更新」
                                             │
                                             ▼ あとで /issue-start
                                          差分を見てカスタマイズを壊さず反映、version を更新
```

## 還元: 利用プロジェクト側の動き

### 1. 判定（Phase 8 手順 5）

知見ボードに書く各気づきに `**還元先**: プロジェクト固有 / テンプレート汎用` を付ける。判定基準は `.claude/rules/workflow-feedback.md`（Copilot 版は `workflow-feedback.instructions.md`）の「還元する / しないの判定」表。一言でいうと **「テンプレートを新規に使う別プロジェクトでも同じ問題が起きるか」**。

| テンプレート汎用（還元する） | プロジェクト固有（還元しない） |
|---------------------------|----------------------------|
| `/issue-start` の手順・Phase 構成・確認の粒度 | `tech-stack` / `coding-standards` の中身 |
| 汎用 rules（git-conventions 等）の規約そのもの | プロジェクト固有の MCP 構成・権限設定 |
| hooks / agents / skills / CI の挙動・判定ロジック | 特定言語・フレームワークに閉じたハマりどころ |
| Issueテンプレート・セットアップ手順の不備 | チーム運用の都合による独自ルール |

### 2. 抽象化と確認（Phase 8 手順 6）

テンプレート元は公開リポジトリなので、還元 Issue には **プロジェクト固有情報を含めない**：

- コード断片・ファイルパス・内部識別子・URL
- 顧客名・社内システム名・人名
- 認証情報・環境変数の値
- 非公開プロジェクトならリポジトリ名も書かず「非公開プロジェクト」とする

抽象化後の本文を提示し、**ローカル知見ボードへの承認とは別に** Y/E/N 確認を取る。無人起票はしない。起票前にこのリポジトリの既存 Issue を検索し、近いものがあれば新規起票ではなくコメント追記を提案する。

### 3. 起票

GitHub MCP の `issue_write`（`owner` / `repo` をこのリポジトリにする）または `gh issue create -R Sakuya398-Yamada/issue-driven-dev-starter --label feedback` で起票する。重複チェックは `search_issues` の `owner` / `repo` 引数でこのリポジトリに絞って行う。本文は Issue テンプレート「テンプレートへの知見還元」（`.github/ISSUE_TEMPLATE/template-feedback.md`）と同じ構成。権限が無い・失敗した場合は本文をユーザーに提示して手動起票を案内し、フローは止めない。

起票できたら、ローカル知見ボードの元コメントの `還元先` を `テンプレート汎用（↗ 還元済み: <Issue URL>）` に編集して二重還元を防ぐ。

> `feedback` ラベルを API 経由で付けられるのはこのリポジトリの collaborator のみ。第三者からの還元 Issue はラベル無しで届くので、こちら側のトリアージで付ける。

## 還元: テンプレート側（このリポジトリ）の動き

1. `feedback` Issue が届く。内容を精査し、対応するなら完了条件（DoD）を埋める。対応しないなら理由を書いて `not_planned` でクローズする
2. 対応する Issue は通常どおり `/issue-start` で実装する。**`template/` と `template-copilot/` の両方** に反映し、README / docs を追従する。hooks を触ったら `tests/test-hooks.sh` を通す（CI でも走る）
3. マージすると release-please が「次の版にする Release PR」を自動で作る（既に開いていれば更新する）。版番号・CHANGELOG・2 つの `template-version` の書き換えはこの PR に含まれるので、**手で version を上げない**
4. Release PR をマージすると、タグ（`vX.Y.Z`）と GitHub Release が自動で切られる（次節）

## 更新: リリースと版番号

### 版番号（SemVer）

| 上げる桁 | 目安 | 利用プロジェクト側の作業 |
|---------|------|--------------------|
| **major** | ファイル構成の変更・Phase の追加削除・hooks の入出力仕様変更など、手動マージが要る | Release notes の「手動対応」に従う |
| **minor** | Phase 手順・rules・agents の追加や大きめの文言変更 | 差分をそのまま当てる（カスタマイズ済みファイルは趣旨だけ取り込む） |
| **patch** | 誤字・軽微な文言修正 | 差分をそのまま当てる |

### リリース手順（メンテナ）

リリースは [release-please](https://github.com/googleapis/release-please-action)（`.github/workflows/release-please.yml`）が自動化している。

1. `main` に変更が入るたびに release-please が **Release PR**（タイトル `chore: release vX.Y.Z`）を作成・更新する。中身は `CHANGELOG.md`・`version.txt`・`.release-please-manifest.json`・`template/.claude/template-version`・`template-copilot/.github/template-version` の版の書き換え
2. 複数の変更をまとめて 1 つの版にしたいなら、Release PR はそのまま開けておく（main に追加で入るたびに自動で追従する）
3. **Release PR をマージする**。これだけでタグ `vX.Y.Z`・GitHub Release・Release notes（CHANGELOG と同じ内容）が作られ、利用プロジェクト側の更新チェックが反応するようになる
4. 利用プロジェクト側で手作業が要る変更（ファイル構成変更・hooks の入出力変更など）があれば、Release の本文を編集して「手動対応」節を手で足す（v2.0.0 の例: [migration-v2.md](migration-v2.md)。major 版では `docs/migration-vN.md` を用意し、Release 本文からリンクする）

版の決め方は Conventional Commits から自動で決まる：

| コミット | 上がる桁 |
|---------|---------|
| `feat!:` / 本文に `BREAKING CHANGE:` | major |
| `feat:` | minor |
| `fix:` / `refactor:` / `docs:` / `chore:` | patch |
| `test:` / `style:` のみ | リリースされない（CHANGELOG 非表示のため） |

設定は `release-please-config.json`。`changelog-sections` に載せた type だけがリリース対象になる（release-please は CHANGELOG が空になる変更ではリリース PR を作らない）。特定の版にしたいときはコミット本文に `Release-As: vX.Y.Z` フッターを書く。

> **前提設定**: リポジトリの Settings → Actions → General → Workflow permissions で「Allow GitHub Actions to create and approve pull requests」を ON にしておく。OFF だと release-please が PR を作れずに失敗する。

## 更新: 利用プロジェクト側の動き

### 版の記録

利用プロジェクトは `.claude/template-version`（Copilot 版は `.github/template-version`）を持つ：

```
repo=Sakuya398-Yamada/issue-driven-dev-starter
# x-release-please-start-version
version=v1.0.0
# x-release-please-end
```

テンプレートに同梱されているので、セットアップ時に記入するものは無い。`x-release-please-...` の 2 行はテンプレート元の release-please がリリース時に `version` を書き換えるための印で、利用プロジェクト側では無害なので残しておいてよい（消しても hook は動く）。フォークして独自テンプレートにする場合だけ `repo` を書き換える。

### 更新チェック（Claude Code 版: SessionStart hook）

`session-start-info.sh` が `git ls-remote --tags --sort=-v:refname` で `repo` の最新 `v*` タグを取り、`version` と `sort -V` で比較して、最新タグの方が新しいときだけ `## Template version` バナーに更新ありを出す（等しい、または `version` の方が新しければ `up to date`）。結果は `.git/template-version-check` に 24 時間キャッシュするので、毎セッションの起動遅延はほぼ無い。キャッシュの版が `version` より古い（更新を取り込んだ直後）場合はキャッシュを捨てて再取得する。オフラインや取得失敗時は `Latest: unknown` を出して黙ってスキップする。

キャッシュのため、新リリース直後はバナーが前の版のまま（`up to date`）で、別セッションや週次ルーティンが起票した更新用 Issue の版と食い違うことがある。その場合は上記の `git ls-remote` を直接打って確認する（Phase 1 手順 0.5 に同じ注記がある）。

```
## Template version
- ⚠ **Template update available**: local `v1.0.0` → latest `v1.2.0` (`Sakuya398-Yamada/issue-driven-dev-starter`)
- Release notes: https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/releases/tag/v1.2.0
- Diff: https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v1.0.0...v1.2.0
```

Copilot 版では自動のバナーを使わず、`/issue-start` Phase 1 手順 0.5 で同じ `git ls-remote` を打って比較する。

### 一度だけ聞く（Phase 1 手順 0.5）

バナーに更新ありが出ていれば、`/issue-start` の Phase 1 冒頭で **セッションにつき一度だけ** 「更新用 Issue を起票しますか？」と聞く。一致していれば何も言わない。

- **[Y]**: 利用プロジェクトに `refactor: テンプレートを vX.Y.Z に更新` の Issue を起票する（Release notes と compare URL、取り込み手順の DoD 付き）。**今の Issue の作業はそのまま続ける**。1 Issue = 1 PR を守るため、作業中のブランチでテンプレートを直接書き換えることはしない
- **[N]**: そのセッション中は再度聞かない。次のセッションでバナーが出れば改めて聞く

### 取り込み（更新用 Issue を `/issue-start` したとき）

利用プロジェクト側のファイルはカスタマイズ済みなので、**機械的に上書きしない**：

1. Release notes と差分（`git diff vOLD..vNEW -- template/`、または compare URL）で変更ファイルを把握する
2. 変更ファイルごとに `git merge-file` で 3-way マージする（現プロジェクト版 = `git show HEAD:<path>`、旧版 / 新版 = テンプレート元クローンの `git show vOLD:template/<path>` / `vNEW:template/<path>`）。テンプレート側の変更は自動で当たり、プロジェクト固有の記述とぶつかる箇所だけがコンフリクトとして残るので、確認範囲を絞れる。コンフリクトは、テンプレート由来の部分（phases・汎用 rules・hooks・agents・skills）ならテンプレート側を優先し、カスタマイズ済みファイル（`tech-stack` / `coding-standards` / `CLAUDE.md` の固有部分 / `settings.json`）なら固有の記述を残して趣旨だけ取り込む
   - Windows で `core.autocrlf=true` の場合、作業ツリーのファイルは CRLF なので全行が衝突する。現プロジェクト版は作業ツリーではなく `HEAD` から取る
   - コマンド一式は利用プロジェクト側の `workflow-feedback.md`（Copilot 版は `workflow-feedback.instructions.md`）「3-way マージの定型手順」にある
3. `template-version` の `version` を新しい版に更新する
4. hooks を変えたなら Claude Code を再起動し、バナーが `up to date` になることを確認する

## フォークして独自テンプレートにする場合

自分のチーム用にこのリポジトリをフォークしてテンプレートを育てる場合は、還元先と更新元をフォーク側に向ける：

1. フォーク側に `feedback` ラベルを作る（`gh label create feedback --color 1D76DB --description "テンプレート利用プロジェクトからの知見還元"`）
2. `template/.claude/template-version` と `template-copilot/.github/template-version` の `repo` をフォークに書き換える
3. `template/.claude/rules/workflow-feedback.md` と `template-copilot/.github/instructions/workflow-feedback.instructions.md` の「テンプレート元の情報」のリンクも書き換える
4. フォーク側でも release-please を動かす（`.github/workflows/release-please.yml` と `release-please-config.json` はそのまま使える。版番号を振り直すなら `.release-please-manifest.json` と `version.txt` を書き換え、`release-as` を調整する）

フォーク側で溜まった汎用の知見を、さらに上流（このリポジトリ）に還元してもらえると嬉しい。

## 設計上の判断

- **還元先を Issue にした**理由: label・state・assignee・`closes` がそのまま使え、テンプレート側で通常の `/issue-start` に乗る。知見ボードへのコメント方式だと「棚卸しして Issue に昇格」という手作業が一段挟まる
- **更新チェックを SessionStart hook に置いた**理由: 「機械判定できるものは hook で決定論的に」というこのテンプレートの原則そのまま。`/issue-start` の Phase 内で毎回聞くと回りくどいので、判定は hook、質問は Phase 1 で一度だけ、に分けた（Copilot 版は hook の出力がコンテキストに入る保証が無いため Phase 1 で判定まで行う）
- **更新を「Issue 起票」で止める**理由: 作業中の Issue のブランチでテンプレートを書き換えると 1 Issue = 1 PR が崩れる。更新は独立した Issue / PR にする
- **無人投稿・無人更新をしない**理由: 還元先は公開リポジトリで、投稿内容にプロジェクト固有情報が混ざるリスクがある。更新も利用側のカスタマイズを壊し得る。どちらも人間が一度読む
- **リリースを release-please に任せた**理由: 「還元 Issue をマージしたら Release を切る」を人が覚えておく運用は続かない。コミット規約が Conventional Commits 互換なので、Release PR をマージするだけで版・タグ・`template-version` が揃う形にした
- **自動同期機構（git subtree / スクリプト）を持たない**理由: 利用プロジェクトはテンプレートを必ずカスタマイズしており、機械的な上書きは事故の元。差分レビュー＋手動反映を明示的な手順として置くに留めた
