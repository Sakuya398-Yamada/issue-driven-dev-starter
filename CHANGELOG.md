# Changelog

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
