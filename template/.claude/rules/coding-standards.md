# コーディング規約

`.claude/rules/` 配下のため起動時に自動で読み込まれる。

<!-- TODO: プロジェクトの言語・フレームワークに合わせて書き換える。以下は TypeScript プロジェクトの記入例。
     言語固有の規約が長くなるなら、frontmatter に `paths:`（例: paths: ["src/**/*.ts"]）を付けて
     該当ファイルを扱うときだけ読み込まれるようにするとコンテキストを節約できる（documentation-policy.md 参照） -->

## 基本方針

- 言語は **<言語名>** で統一する
- <型安全性・リント等の方針>

## ディレクトリ構成

```
<プロジェクトルート>/
├── CLAUDE.md            # コア原則＋rules への索引
├── .mcp.json            # プロジェクト共通の MCP サーバー（GitHub）
├── src/
│   └── ...
└── .claude/
    ├── agents/          # サブエージェント定義
    ├── rules/           # 自動読み込みされる規約集
    ├── hooks/           # PreToolUse / SessionStart で使うシェルスクリプト
    ├── settings.json    # 権限と hooks の登録
    └── skills/          # /issue-start, /issue-plan
```

## 命名規約

<!-- 記入例（TypeScript の場合） -->

| 対象 | 規約 | 例 |
|------|------|----|
| ファイル名 | `kebab-case` | `user-data.ts` |
| クラス・コンポーネント | `PascalCase` | `UserList` |
| 変数・関数 | `camelCase` | `calculateTotal` |
| 定数 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 型・インターフェース | `PascalCase` | `UserData` |

## コメントとドキュメント

- 自明なコードにコメントは付けない
- ロジックが直感的でない場所のみ「なぜそうしたか」を書く
- 触っていないコードに後付けで型注釈・コメント・docstringを追加しない
