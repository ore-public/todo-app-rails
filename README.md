# Tag Todo

タグと実施日で整理する TODO アプリです。

- 1 行の入力で todo を追加できます（`資料作成 #仕事 @tomorrow !+3d` のように、`#タグ`、`@実施日`、`!期限` を指定できます）。
- 一覧は実施日ごとにまとめて表示し、タグと完了状態で絞り込めます。
- キーボードだけで操作できます（`?` でショートカットの一覧を表示します）。

## 構成

- Ruby 4.0、Rails 8.1、SQLite
- Haml、Hotwire（Turbo と Stimulus）
- JavaScript は jsbundling-rails と Bun、CSS は dartsass-rails と Bootstrap でビルド
- RSpec（system spec は Playwright で Chrome を動かす）

## 開発の始め方

Ruby、[Bun](https://bun.sh/)、Google Chrome を用意してから、次を実行します。

```sh
bin/setup
```

依存関係のインストール、アセットのビルド、DB の作成、Git の pre-commit フックの設定をして、開発サーバー（`bin/dev`）を起動します。

## 検査とテスト

```sh
bin/ci
```

GitHub Actions と同じ検査（RuboCop、haml-lint、ESLint、stylelint、i18n-tasks、brakeman、bundler-audit、bun audit、database_consistency、RSpec とカバレッジ）をまとめて実行します。

PR では、GitHub Actions が次のコメントを付けます。このリポジトリのブランチから作った PR が対象で、フォークと Dependabot の PR には付けません。

- 検査ツール（RuboCop、haml-lint、ESLint、stylelint、Brakeman）の指摘: 変更した行へのレビューコメント（reviewdog）
- spec で実行されていない変更: 変更したメソッドやブロックのうち、実行されていない行へのレビューコメント（undercover と reviewdog）
- カバレッジの要約: 全体とディレクトリごとの割合と、実行されていない箇所の一覧。push のたびに同じコメントを更新します

## コーディング規約

- [docs/coding_rules.md](docs/coding_rules.md): 規約の一覧と、それぞれをどのツールで検査しているか
- [AGENTS.md](AGENTS.md) と各ディレクトリの `AGENTS.md`: ツールで検査できない規約。AI エージェントがコードを書くときとレビューするときに読みます
