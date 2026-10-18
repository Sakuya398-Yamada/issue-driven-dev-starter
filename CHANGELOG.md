# Changelog

## [2.2.0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.6...v2.2.0) (2026-10-18)


### 追加・変更

* 検証 hook が検証できなかったときに通さず止める（onFailure: "block"、パーサーが無いときは exit 2） [#153](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/153) ([#154](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/154)) ([0fc4afd](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/0fc4afd5836229ce2e4e839920f15ddd07dac1b1))


### 修正

* /template-update に、テンプレートが持ち込んだ印・規約をテンプレート外の記述や Issue コメントが参照していないかの確認を足す [#108](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/108) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* Phase 1 のチェックリストに未確定事項の行を足し、Issue テンプレートの「[要確認] は Phase 1 で質問になる」と揃える [#127](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/127) ([d5c502d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c502d1cff402e57549d54cf4e1d4228647718f))
* pitfalls の「Issue に関連する PR」を URL で出し、別リポジトリの PR をこのリポジトリの PR と取り違えないようにする [#126](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/126) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* シンボリックリンク経由で開いても作業環境チェックと ghost worktree の検出が誤らないよう、pwd -P で比べる [#142](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/142) ([af10c58](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af10c58989f904578d1d36cda8bd9657343d0ecf))
* 完了条件が空の Issue は、不足時の対応で聞かず Phase 1.5 で作って確認する、と Phase 1 のチェックリストに書く [#141](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/141) ([af10c58](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af10c58989f904578d1d36cda8bd9657343d0ecf))
* 常駐の「確認ポイントで止まる」に Issue の記載不足の確認（Phase 1）を足し、SKILL.md「全体ルール」と揃える [#137](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/137) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))


### ドキュメント

* /issue-plan に、質問して止まるか未確定事項に回すかと、依頼された調査の扱いの線引きを足す [#112](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/112) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* /issue-start Phase 1 で、この Issue を参照している Issue・PR（申し送り）を timeline から拾う [#117](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/117) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* code-reviewer / code-explorer の定義に、リポジトリと呼び出し元の一時ファイルを書き換えない制約を足す [#123](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/123) ([d5c502d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c502d1cff402e57549d54cf4e1d4228647718f))
* hook の所要時間を延ばしたら、登録した timeout に収まるかを確かめる [#150](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/150) ([#152](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/152)) ([a6c8539](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/a6c85399908ced8d1e817aaa53adf2255bb5b462))
* main の取り込み前に、この PR が触ったファイルに並行マージで入った変更を読み、意味的な重複を確かめる [#134](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/134) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* MCP が無いときの gh へのフォールバックに、クラウドセッションでは GraphQL 系が 403 になり REST に置き換えることを書く [#143](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/143) ([af10c58](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af10c58989f904578d1d36cda8bd9657343d0ecf))
* MCP が無いときの代わりの経路を変えた skill は、MCP を使わない前提で回して検証する [#139](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/139) ([af10c58](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af10c58989f904578d1d36cda8bd9657343d0ecf))
* Phase 6 手順 7 のスコープ内の指摘は直して共有し、聞くものを全体ルールの確認ポイントに揃える [#110](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/110) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* PR 作成後に行う DoD が残るなら本文に明記し、マージ後の作業なら closes ではなく refs にする [#133](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/133) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* skill の判定の文言を変えたら、変更前の文言でも対象の入力を空回しして結果の差を確かめる [#119](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/119) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* skill の検証に、編集直後の古い内容の確かめと新しいコンテキストでの空回しを足す [#109](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/109) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* クラウドセッションで gh api から Issue 本文を編集すると署名フッターが付くことを pitfalls に足す [#125](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/125) ([d5c502d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c502d1cff402e57549d54cf4e1d4228647718f))
* クラウドセッションで還元の重複チェックを未確認にする前に、承認を得てテンプレート元をセッションに足す [#147](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/147) ([7e9b8ce](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/7e9b8cef17ea01bae0a2fae896968f04a46df344))
* クラウドセッションの git プロキシの挙動（別ブランチへの push は通る・削除は通らない・shallow clone）を pitfalls に足す [#132](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/132) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* たまにしか起きないバグは、直す前に落ちる再現条件を作って直す前と後を比べる [#144](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/144) ([#148](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/148)) ([acaf3d0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/acaf3d07c1eeae8795825e8477b340e232809675))
* ツールに拒否・エラーで止められた気づきは、メッセージの原文を引用して記録する [#115](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/115) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* テンプレート元をセッションに足すかを、最初にテンプレート元に触れる知見ボードの手順 3 で 1 回だけ聞く [#149](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/149) ([7e9b8ce](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/7e9b8cef17ea01bae0a2fae896968f04a46df344))
* ドメイン仕様に依存する境界条件は、設計承認に同梱せず、仕様の質問として別に聞く [#135](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/135) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* リポジトリへの変更が出ない Issue の分岐を、GitHub 上の操作だけで終わる Issue にも広げる [#124](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/124) ([d5c502d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c502d1cff402e57549d54cf4e1d4228647718f))
* 作業環境チェックで、メインのチェックアウトと linked worktree を --git-dir と --git-common-dir で見分ける [#130](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/130) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* 作業環境チェックの worktree 作業の行で、隔離が掛かる起動形態と掛からない手動 worktree を分けて書く [#129](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/129) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))
* 利用者から見える挙動を変える Issue では、README など利用者向けドキュメントの食い違う記述も影響範囲として拾う [#114](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/114) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* 手順に載せたコード・コマンドは md から機械的に抜き出したもので検証する、を Phase 5 に足す [#111](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/111) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* 手順書・規約から人の確認を外す変更は、1 文で説明できても Phase 4 を省かず文面の承認を取る [#113](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/113) ([1327de9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1327de96151fc01f88101e90962769b239883d6b))
* 更新用 Issue の本文でテンプレート元の Issue に触れるときは owner/repo#N で書く [#146](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/146) ([7e9b8ce](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/7e9b8cef17ea01bae0a2fae896968f04a46df344))
* 書き方のパターンが原因のスコープ外問題は、起票前に同じ書き方をリポジトリ全体で探して 1 つの候補にまとめる [#138](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/138) ([af10c58](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af10c58989f904578d1d36cda8bd9657343d0ecf))
* 確認ポイントの Y/E/N を AskUserQuestion の選択式の質問で聞くよう、聞き方を全体ルールに定める [#116](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/116) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* 空回しとレビューで見つかった、/issue-start と /issue-plan の前からある手順の曖昧さ 12 件を直す [#128](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/128) ([d5c502d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c502d1cff402e57549d54cf4e1d4228647718f))
* 親 Issue の作業中に起票する子 Issue が親の未マージの変更を前提にするなら、本文に依存を書く [#118](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/118) ([b9f8d30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b9f8d30c8546f263dfadb97269a0f6a4d1b449a2))
* 設計で近似・既知の制限を置くなら、最悪の入力での結果を設計案に添え、テストで確かめる [#131](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/131) ([204168a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/204168a0ce006a8768dba2833ae6702b6aa2ef01))

## [2.1.6](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.5...v2.1.6) (2026-10-18)


### 修正

* /template-update の書き戻しを Edit で当てて cmp で確かめ、cp で auto mode に止められないようにする [#101](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/101) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))
* template-update の CR 除去を tr にし、pitfalls の関連 PR をタイムラインから引いて古い PR を落とさないようにする [#105](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/105) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))
* クラウドセッションで gh api --paginate が 2 ページ目に 403 で止まる回避を pitfalls に足す [#100](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/100) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))
* クラウドセッションで git reset --keep が拒否されたときの代替手順を Phase 2 に足す [#103](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/103) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))
* 前の Issue を中断して移るとき、前の Issue に残った着手の印を取り下げに書き換える [#104](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/104) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))


### ドキュメント

* Phase 5 のコミット前の検証に、分岐を一時的に外してテストが落ちるかを確かめる手順を足す [#102](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/102) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))
* 追加・変更した skill は作業中のセッションで呼んで検証できることを Phase 5 に書く [#99](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/99) ([26fdee2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/26fdee2fe7d0419b4b7c0a30337e9830596d4201))

## [2.1.5](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.4...v2.1.5) (2026-10-18)


### ドキュメント

* CLAUDE.md の rules 自動読み込みの説明に、paths: 付き rules の例外を書く [#93](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/93) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))
* paths: 付き rules の読み込みを InstructionsLoaded hook で確かめる手順を足す [#92](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/92) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))
* Phase 6 のレビュー観点に、記述を移す・まとめる変更での削除行の照合を足す [#96](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/96) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))
* 完了条件に数値目標を置くときは、現状値を測って届くかを確かめる [#95](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/95) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))
* 置き場所を変える設計では、移動先ごとの層と読み込まれる契機を Phase 4 の設計案に書く [#91](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/91) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))
* 起動ディレクトリがリポジトリ直下でないと settings.json が読まれないことを Phase 1 手順 0 に足す [#94](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/94) ([90dd858](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90dd858634affb3fccba93e4103037922c7ba2f8))

## [2.1.4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.3...v2.1.4) (2026-10-17)


### 修正

* /template-update の clone に core.longpaths=true を付け、Windows では --no-checkout でも Filename too long で止まらないようにする [#74](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/74) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))
* code-reviewer の既定レビュー範囲を git fetch 後の origin/main...HEAD にそろえる [#84](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/84) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))
* Phase 1 の兄弟 Issue の照合で、sub-issue 一覧は番号・タイトル・状態だけを取り、本文は候補だけ個別に読む [#87](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/87) ([272d2ef](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/272d2ef4e03d455cef196fab8dd4cc3711fe37e9))
* クラウドセッションの割り当てブランチを claude/* 以外の名前でも判定し、マージ済みの残りを付け直す手順を足す [#89](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/89) ([272d2ef](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/272d2ef4e03d455cef196fab8dd4cc3711fe37e9))


### ドキュメント

* Bash ツールの pkill -f が自分のシェルに一致する件と止め方を pitfalls に足す [#80](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/80) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))
* subagent_type が見つからないときは general-purpose に定義ファイルを読ませる代替を SKILL.md に足す [#82](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/82) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))
* クラウドセッションで gh の GraphQL 系が使えないときの REST への読み替えを pitfalls に足す [#83](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/83) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))
* 設計承認までは作業ツリーを変えず、試作はリポジトリの外で行う手順を Phase 3・4 に足す [#88](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/88) ([272d2ef](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/272d2ef4e03d455cef196fab8dd4cc3711fe37e9))
* 起動時に読まれる設定の変更は PR ブランチで開いた別セッションで検証する手順を Phase 5 に足す [#79](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/79) ([9c8bedb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9c8bedb4aed37a717cc86a5db603817be04350d9))

## [2.1.3](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.2...v2.1.3) (2026-10-15)


### 修正

* クラウドセッションでは割り当て済みの claude/* ブランチで /issue-start を進める [#76](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/76) ([#77](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/77)) ([56d96cb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/56d96cb2c5330a23c417a95b0f701e3dd8048361))

## [2.1.2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.1...v2.1.2) (2026-10-15)


### 修正

* CHANGELOG に同じ変更が 2 行載らないよう、PR を squash マージに統一する運用を明記する [#64](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/64) ([#71](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/71)) ([568da75](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/568da7508387c481e806ac44b79a3318f4c3616c))


### ドキュメント

* v2.1.1 の文面の不整合 3 件（hook のコメント・見出しの重複・節番号の参照）を直す [#67](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/67) ([b38d36b](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b38d36bdc21f1fd2da1dd05ecaf4ec70bfd72658))
* v2.1.1 の文面の不整合 3 件（hook のコメント・見出しの重複・節番号の参照）を直す [#67](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/67) ([90a4c17](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/90a4c17de32f3fa09f9855dfa51df35e757a3c98))
* 利用プロジェクト向けの常駐コンテキスト予算を 1000 行にし、テンプレート元の CI 予算と分ける [#65](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/65) ([ce3d0f4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/ce3d0f4aca2193591284a1b4a3d1d4780671c265))
* 利用プロジェクト向けの常駐コンテキスト予算を 1000 行にし、テンプレート元の CI 予算と分ける [#65](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/65) ([f8955b7](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/f8955b730d4eb15972745c2457d5842699fa121f))
* 手順を別ファイルへ移すリリースの取り込みで、移動元の固有記述を移動先へ移す確認を追加 [#66](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/66) ([#73](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/73)) ([779f808](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/779f8083b246c5a04c5853410c66ee9e340d739c))
* 調査だけの Issue で変更が出なかった場合の進め方を /issue-start に追加する [#60](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/60) ([#72](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/72)) ([f49a44a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/f49a44a29c109fae4d741fd9b92f56b461223886))

## [2.1.1](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.1.0...v2.1.1) (2026-10-13)


### 修正

* テンプレート更新チェックで最新タグを毎回取得し、キャッシュは取得失敗時のフォールバックに限る [#61](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/61) ([23d2ac5](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/23d2ac5e0274b061d69fd356e96f89a7c0b5dd1f))
* テンプレート更新チェックで最新タグを毎回取得し、キャッシュは取得失敗時のフォールバックに限る [#61](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/61) ([2a9c359](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/2a9c3596d920ee80020add446733f9e1bb52f80b))

## [2.1.0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.0.4...v2.1.0) (2026-10-13)


### 追加・変更

* 常駐コンテキストの行数予算を CI で検査する check-context-budget.py を追加 [#46](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/46) ([ea45609](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/ea45609ed4709b0b407d1daa0df686ec966663dc))
* 常駐コンテキストの行数予算を CI で検査する check-context-budget.py を追加 [#46](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/46) ([8e2f006](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/8e2f0066ac581593a10cdb4a53854d1669b5dc02))


### 修正

* Git Bash で既定ブランチの template-version が読めない MSYS のパス変換を回避する [#42](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/42) ([41b1a16](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/41b1a16d995b93b81a4c3fb341655673b8aca41b))
* Git Bash で既定ブランチの template-version が読めない MSYS のパス変換を回避する [#42](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/42) ([c99357f](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/c99357fbffc20f6245ebcd6923c9a48a668fcbad))
* SessionStart バナーに hook の実行ディレクトリを出し、起票前に作業ツリーと既定ブランチの版を確かめる [#43](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/43) ([85153b8](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/85153b862368468ceee8f67b28eeb59bb8989c4e))
* SessionStart バナーに hook の実行ディレクトリを出し、起票前に作業ツリーと既定ブランチの版を確かめる [#43](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/43) ([60c3ec4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/60c3ec4a44701d217a6d4910d8e8aa1f8e4f1eae))


### リファクタリング

* レビュー指摘を反映し、移動時に落ちた注意書きと文言の精度を復元 [#44](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/44) ([6983a81](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/6983a81de9af387b560a064d70d0502f03ad22a2))
* 取り込み手順を template-update skill に移し、workflow-feedback を判定表と参照だけにする [#44](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/44) ([c16d855](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/c16d8554a8e2d2a7ef97f9422c9336ea2e1580e6))
* 常駐 rules から手順を skill / phases に移し、重複記述を正本 1 箇所に統一する [#44](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/44) ([6657f56](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/6657f5691abae8d8907840c7b9d32523b25ef847))
* 常駐 rules と CLAUDE.md の重複・冗長部分を圧縮し、粒度の判定表を issue-plan に移す [#44](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/44) ([b29af3e](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b29af3ecd18379c166caee4b69625da3fa0b1366))


### ドキュメント

* customization.md に無人実行（スケジュール実行）向けの /issue-start 読み替え指針を追加 [#47](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/47) ([5085792](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/5085792b52115d0e39502d371ccca17c6f0c446a))
* customization.md に無人実行（スケジュール実行）向けの /issue-start 読み替え指針を追加 [#47](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/47) ([397bb0b](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/397bb0b7bcfa3c681f6badd0502132fa68424815))
* docs ラベルでも手順・コマンドを含むランブックは Phase 6 のレビューをスキップしない [#52](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/52) ([7d9c15d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/7d9c15db5f9eedd5c724b5336886d93658a00aca))
* docs ラベルでも手順・コマンドを含むランブックは Phase 6 のレビューをスキップしない [#52](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/52) ([b348c1d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/b348c1de2f2082e5ba589e1fbae578c6480d8edb))
* Phase 1 で兄弟 Issue との共通変更の重なりを確認する [#39](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/39) ([669c49d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/669c49de20b225e3cec8200ebe8646391658a158))
* Phase 1 で兄弟 Issue との共通変更の重なりを確認する [#39](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/39) ([1d73948](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1d73948fb5b30ad201d25ad683f49dac3a40cdbd))
* template-update skill と正本の移動に合わせて README / docs の参照先を追従 [#44](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/44) ([48d150f](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/48d150f06b0837c1df0485973007381d84400641))
* ハマりどころの書き先を 4 択で仕分け、環境依存の注記を pitfalls.md に隔離する [#45](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/45) ([67384e5](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/67384e5d7ef8b8b300d87adc70eda5b94aaf8367))
* ハマりどころの書き先を 4 択で仕分け、環境依存の注記を pitfalls.md に隔離する [#45](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/45) ([5518c0e](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/5518c0ed1d887c944a9b96584050b9384e553846))
* 残っていた参照の食い違い 2 件と .gitignore の抜けをまとめて直す [#53](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/53) ([f892bfa](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/f892bfa87bfdf6cccded538e7fede0d67d81ef08))
* 残っていた参照の食い違い 2 件と .gitignore の抜けをまとめて直す [#53](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/53) ([41d1f2b](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/41d1f2bb493d8b059999b9b08d99f46d5ea53cf8))

## [2.0.4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.0.3...v2.0.4) (2026-10-12)


### 修正

* テンプレート更新チェックで既定ブランチの版も読み、作業ブランチが古いだけなら更新ありと出さない [#36](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/36) ([af1dfeb](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/af1dfeb9ff80cf6ad50093768bf1c8929becbf21))
* 還元 feedback 6件（heredoc のエスケープ / 残差の前後比較 / バナー直接確認 / 既定ブランチの版 / CRLF / push 前の main 追従）に対応 ([bf733fe](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/bf733fe56f0ae18352d193fd01634f2e266c740b))


### ドキュメント

* PR 作成前の push 前チェックに origin/main への追従確認を追加 [#38](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/38) ([058b193](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/058b19365ec03e6806b5ddb899e5c79a3530041d))
* Windows で sed -i 等の機械置換が CRLF を LF に変える注意を追加 [#37](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/37) ([9dfeb34](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9dfeb34dcef3afc78ac48ef1b689ce697a04344d))
* バックスラッシュを含むスクリプトをヒアドキュメントで書き出さない注意を追加 [#33](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/33) ([e9a4370](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/e9a4370cdfc3b71345f26dcec2dff8b8bbab9451))
* 取り込み後のバナー確認を再起動ではなく hook の直接実行に変更 [#35](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/35) ([76ce42a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/76ce42ac84143287cc2808baba0d9985522f9870))
* 残差確認に取り込み前後の残差を突き合わせるスニペットを追加 [#34](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/34) ([14d0096](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/14d00968a51f13dcdc8c5defda90969658d1aaef))

## [2.0.3](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.0.2...v2.0.3) (2026-10-12)


### ドキュメント

* 3-way マージ定型手順に、書き戻し後のテンプレート版との残差確認を追加 [#26](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/26) ([bcfc281](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/bcfc28134ef98c4414ff111c2fd3efe96eb75833))
* Phase 1 に外部リポジトリの特定タグのファイルを版固定で参照する手順を追加 [#28](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/28) ([eff0d01](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/eff0d016cbe72a69e5c8d908f17345bc9d4ca967))
* PR 作成がタイムアウト・5xx で失敗しても作成済みの場合がある旨を Phase 7 に追記 [#30](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/30) ([925451d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/925451db5501bffe0427dc8953b6b33b34700aac))
* 実装をサブエージェントに委譲するときは触ってはいけない範囲をプロンプトに含める [#29](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/29) ([79c6928](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/79c6928ee45e60b2a5bd417873bc02c13910783b))
* 更新用 Issue の本文に template/ 配下の変更ファイル一覧を機械的に含める [#27](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/27) ([9d4e6e6](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9d4e6e66b7fb64438584812740b8732aca66d41f))
* 還元 feedback 5件（残差確認 / 変更ファイル一覧 / 版固定参照 / 委譲時の範囲 / PR 作成の 5xx）に対応 ([3b47872](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/3b47872f45f2b558e903cf49fc37ecc2836bee13))

## [2.0.2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.0.1...v2.0.2) (2026-10-10)


### 修正

* commit 検証 hook が引用符内の ; & | を区切りと誤認して件名を取り逃す抜け道を修正 [#18](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/18) ([36840e4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/36840e43180aeaab32dfc5d1c6201cd2ef3e56ea))
* テンプレート更新チェックを版比較にし、ローカルより古いキャッシュは再取得する [#21](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/21) ([fe40b20](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/fe40b20bd7d2e3c082c373dc0e2928e3a6020535))
* 還元 feedback 5件（更新チェックの版比較 / commit hook の引用符 / 3-way clone / 旧 PR 残存時の手順）に対応 ([9a4c0c9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/9a4c0c95c5d6467708c2982dc585c3768289bc99))


### ドキュメント

* 3-way マージ定型手順のテンプレート元 clone を --no-checkout にする [#17](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/17) ([11e37da](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/11e37da3a67378ad2608ef7e387999ed8241d658))
* 同じ Issue にオープンな旧 PR／既存ブランチが残っている場合の手順を追加 [#20](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/20) ([d65abab](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d65abab7cf8b9168a126e98848ebbcf1f1402131))
* 常駐コンテキスト（環境側）の点検指針を customization.md に追加 [#22](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/22) ([c504a4c](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/c504a4cca2ff25f8924aaa88ea59b1e6d53369cc))
* 常駐コンテキスト（環境側）の点検指針を customization.md に追加 [#22](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/22) ([98073d4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/98073d439e89b32ea55206802642111a3c5b1140))
* 更新チェックのバナーと更新用 Issue の版が食い違う場合の確認方法を追記 [#19](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/19) ([be1b6a0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/be1b6a0f1fa9b454d6e46adfc55500398bc7da26))

## [2.0.1](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v2.0.0...v2.0.1) (2026-10-10)


### 修正

* commit メッセージ検証 hook が heredoc 本文や後続コマンドから件名を拾う誤判定を修正 [#14](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/14) ([85812b4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/85812b4200db334f24e4abe77d580ffa9ca08eb8))
* SessionStart hook の timeout 判定を GNU 版の確認に変更 [#13](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/13) ([790f308](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/790f3081e3a34becbaf1c813b84f383a5a605e37))
* 還元 feedback 3件（timeout 判定 / commit 件名抽出 / 3-way マージ手順）に対応 ([ff1f7f5](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/ff1f7f54ca06222e191ef9b25a20822fdc14a172))


### ドキュメント

* テンプレート更新の取り込み手順に 3-way マージ（git merge-file）の定型手順を追加 [#12](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/issues/12) ([4e71bf9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/4e71bf9241619232af1582d1e75166e7d057a2c8))

## [2.0.0](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/compare/v1.0.0...v2.0.0) (2026-10-09)


### 追加・変更

* GitHub MCP サーバー設定 .mcp.json をテンプレートに同梱 ([959875f](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/959875fed03bb9089c8c99ee868407397fdf4b06))
* hooks の回帰テストと正規表現の同期チェックを追加 ([40b87a4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/40b87a4c91febc4c364b1a073cb54aefbe6b332f))
* 要望をIssueに分割・起票する /issue-plan スキルとIssue粒度規約を追加 ([e370d3d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/e370d3dbaeca2d2132d03a07383a3e05eed4161d))
* 要望をIssueに分割・起票する /issue-plan スキルとIssue粒度規約を追加 ([d815935](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d815935b5247f722c5b8915508859d8f79231e87))


### 修正

* hooks の検証漏れを塞ぎ、JSON パーサを jq/node/python3 に切り替え ([fa0c1b2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/fa0c1b2af3273d614c5eb0b69b8b688d6cad53d4))


### リファクタリング

* Claude Code 版テンプレートを現行仕様と最近の知見に合わせて刷新 ([06fb3bc](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/06fb3bc47171d1bf25bb9dc7d9fa2898156f9098))
* Copilot 版テンプレートを現行の Copilot 機構（skills / agents / hooks）に移行 ([bb120fc](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/bb120fc7941fe341604fd23a0e2fbb245acca96c))
* テンプレート全体を現行の Claude Code / Copilot 仕様とエージェント開発の知見に合わせて刷新 ([8df5701](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/8df570133ee4ffacfb4aebf53922eb43a9a8aab1))


### ドキュメント

* README と docs を刷新後のテンプレート構成・仕様に追従させ、参照パスの検査を CI に追加 ([d5c6b07](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/d5c6b0761a3c96c20523718342ff098dc5c6ccde))
* v1.x から v2.0.0 への移行手順（手動対応）を追加 ([342b2b4](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/342b2b4520ec0efd73af0b67ce9ddfe5e1a1ce28))
* v1.x から v2.0.0 への移行手順を追加（Release-As: 2.0.0） ([fbce74f](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/fbce74f5d18d99a891c4992065ef7c2bb8ca17c0))
* 削除済みの release-as 設定への言及を除去 ([4bbc8f3](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/4bbc8f390030db8a10ea2827452a84ca8cdd5267))


### その他

* 初回リリース用の release-as 設定を削除 ([44aeb9c](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/44aeb9cb409b729c4a2e801bb4ae6f3c45e04399))
* 初回リリース用の release-as 設定を削除 ([210c62e](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/210c62ed11567b6876600499ec0009158dbf157b))

## 1.0.0 (2026-10-05)


### 追加・変更

* GitHub Copilot向けテンプレートとクイックスタートガイドを追加 ([416a27a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/416a27aa781f3bb1894d0f0d7b19f8be509a9827))
* GitHub Copilot向けテンプレートとクイックスタートガイドを追加 ([20c80c3](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/20c80c31c2df0f11df211442493853129a460b5b))
* Issueテンプレート（feature/bug/refactor/docs）を両テンプレートに追加 ([f1c988c](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/f1c988c3e5958ed3c0dbc3e63506abf0ad939593))
* Issueテンプレート（新規Issue / 知見ボード）を追加 ([c3cc6e2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/c3cc6e2959d53c2e266ad55c7f55a380bf1c6664))
* Issue駆動開発スターターキット初版（テンプレート＋クイックスタートガイド） ([83b4375](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/83b4375f9947d54deb4ec26405a79ed9694a4941))
* 利用プロジェクトからテンプレートへの知見還元フローを追加 ([1d8bab2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1d8bab26aa2f7d4bda55599d68d4b3749e06ab7d))
* 利用プロジェクトとの知見還元・テンプレート更新チェック・release-please を追加 ([6f68a1a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/6f68a1acc06e19dc168578ba6098e845e7a86c93))


### リファクタリング

* Issueテンプレートを新規Issue用と知見ボード用の2種に統合 ([76c897d](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/76c897d733dc0b2093c83acf1dc9c84b77e465d8))
* 知見還元をIssue起票方式に変更し、テンプレート更新チェックを追加 ([377e4f2](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/377e4f223f6681959ffce9def25bff7516091b1b))


### ドキュメント

* git hooksとGitHub Actionsの解説ガイドを追加 ([8a70c1a](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/8a70c1a5b2baac39cf1cd71056c97df84f0bd368))


### その他

* release-please でテンプレートのリリースを自動化 ([1a4a3f9](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/1a4a3f90d3e41943eb10e79bd628f2243bc389f1))
* このリポジトリ自体にもIssueテンプレートを配置 ([c6d36f1](https://github.com/Sakuya398-Yamada/issue-driven-dev-starter/commit/c6d36f1197c9bb3e7fd430b3bcb9aee4597feb1c))
