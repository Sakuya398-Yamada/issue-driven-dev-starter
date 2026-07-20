# コーディング規約

このファイルは CLAUDE.md から `@.claude/rules/coding-standards.md` でインポートされる。

<!-- TODO: プロジェクトの言語・フレームワークに合わせて書き換える。以下は TypeScript プロジェクトの記入例 -->

## 基本方針

- 言語は **<言語名>** で統一する
- <型安全性・リント等の方針>

## ディレクトリ構成

```
<プロジェクトルート>/
├── CLAUDE.md
├── src/
│   └── ...
└── .claude/
    ├── agents/          # サブエージェント定義
    ├── rules/           # @import される規約集
    ├── hooks/           # PreToolUse 等で使うシェルスクリプト
    ├── settings.json    # フック設定
    └── skills/          # スラッシュ起動可能なスキル
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
