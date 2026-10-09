---
applyTo: "**"
description: "コーディング規約（言語・命名・ディレクトリ構成・コメント方針）"
---

# コーディング規約

<!-- TODO: プロジェクトの言語・フレームワークに合わせて書き換える。以下は TypeScript プロジェクトの記入例。
     言語固有の規約が長くなるなら applyTo を "src/**/*.ts" のように絞り、該当ファイルを扱うときだけ読まれるようにする -->

## 基本方針

- 言語は **<言語名>** で統一する
- <型安全性・リント等の方針>

## ディレクトリ構成

```
<プロジェクトルート>/
├── src/
│   └── ...
├── .githooks/                       # git hooks（commit-msg / pre-push）
└── .github/
    ├── copilot-instructions.md      # コア原則＋instructions への索引
    ├── instructions/                # applyTo で自動適用される規約集
    ├── skills/                      # /issue-start, /issue-plan（Agent Skills）
    ├── agents/                      # code-explorer / code-architect / code-reviewer
    ├── hooks/                       # preToolUse hook（ブランチ名・コミット規約の強制）
    └── workflows/                   # CI（規約検証を含む）
```

## 命名規約

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
