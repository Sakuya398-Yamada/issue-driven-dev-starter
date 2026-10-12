# Changelog

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
