---
applyTo: "**"
description: "コーディング規約（言語・命名・ディレクトリ構成・コメント方針）"
---

# コーディング規約

## 基本方針

- 言語は **<言語名>** で統一する
- <型安全性・リント等の方針>

## ディレクトリ構成

```
<プロジェクトルート>/
├── src/
│   └── ...
├── .githooks/                       # ローカルガードレール（commit-msg / pre-push）
└── .github/
    ├── copilot-instructions.md      # コア原則＋instructions への索引
    ├── instructions/                # applyTo で自動適用される規約集
    ├── prompts/                     # /issue-start 等のプロンプトファイル
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
