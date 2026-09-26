# AGENTS.md

AI エージェント向けの指示です。コードを書くときとレビューするときに従ってください。

## このアプリ

- タグ付きの TODO アプリです。Rails 8.1、Ruby 4.0、SQLite で作っています。
- 画面は Haml と Hotwire（Turbo と Stimulus）で作っています。JavaScript は jsbundling-rails と Bun で、CSS は dartsass-rails と Bootstrap でビルドします。
- テストは RSpec です。system spec は Playwright で Chrome を動かします。

## コマンド

| 目的 | コマンド |
|---|---|
| 開発サーバーの起動 | `bin/dev` |
| すべての検査とテスト（CI と同じ） | `bin/ci` |
| テスト | `bin/rspec`（カバレッジも確認するときは `COVERAGE=true bin/rspec`） |
| Ruby の検査 | `bin/rubocop` |
| Haml の検査 | `bundle exec haml-lint` |
| JavaScript と CSS の検査 | `bun run eslint`、`bun run stylelint` |

## 規約

- 規約の一覧と、それぞれをどう検査しているかは [docs/coding_rules.md](docs/coding_rules.md) にあります。
- ツールで検査できる規約は CI が検査します。このファイルと、各ディレクトリの `AGENTS.md` には、ツールで検査できない規約だけを書いています。
- 作業するディレクトリの `AGENTS.md` もあわせて読んでください。
- 規約を追加・変更するときは、`docs/coding_rules.md` と `AGENTS.md` の両方を直してください。`spec/docs/coding_rules_spec.rb` が両者のずれを検査します。

### 共通

- **COMMON-01** リッチなドメインモデル、Skinny Controller、CRUD のルーティングを基本にする。業務の処理はモデルに書く。
- **COMMON-02** 抽象化は、その価値を説明できるときだけ行う。似たコードが 2 か所あるだけでは共通化しない。
- **COMMON-03** 名前は設計の一部として付ける。
  - 具体的な名前にする（`sum` ではなく `price_in_tax`、`check_xxx` ではなく `image_must_be_allowed_content_type`）。
  - 肯定形のドメインの言葉にする（`not_deleted` ではなく `active`）。
  - 重複を含めない（User の名前は `user_name` ではなく `name`）。
  - `data`、`list` のような抽象的な名前は、使う範囲が狭い場合を除いて使わない。
  - Rails の標準と紛らわしい名前（`create_xxx` など）は避ける。
  - クラスは名詞にする。副作用のあるメソッドは動詞に、副作用のないメソッドは名詞にする。例外を投げるメソッドは `!` で終える。
- **COMMON-04** コメントには、コードから読み取れない意図・仕様・トレードオフだけを最小限に書く。
- **COMMON-10** 一意なキーのカラムは、外部キーと区別するため `xxx_id` ではなく `xxx_key` と名付ける。

### メールとジョブ

- **JOB-01** Mailer には `with` で値を渡し、基本は `deliver_later` で送る。DB の値や時刻に依存する文面は、呼び出すときに値を渡す。
- **JOB-02** Mailer と Job には処理を書かず、モデルのメソッドを呼ぶ。
- **JOB-03** Job の引数には、レコードではなく ID を渡す。大きなハッシュは渡さない。

## レビュー

変更をレビューするときは次のとおりにしてください。

- 確認するのは、このファイルと、変更したファイルがあるディレクトリの `AGENTS.md` に書いた規約です。規約の ID を添えて指摘してください。
- `docs/coding_rules.md` でチェック方法がツールになっている規約は CI が検査し、PR に指摘のコメントを付けるので、指摘しないでください。
- 規約のほかに、変更の意図・品質・保守性・安全性・効率を確認してください。
- 指摘は重要なものから順に書き、1 つの指摘に「問題」「影響」「修正する箇所（ファイル:行）」をそろえてください。
- 変更の範囲外の修正が含まれていれば指摘してください。
- 機能を追加・変更したのに spec がない場合と、機能を削除したのに spec が残っている場合は指摘してください。
- 良い点があれば、それも書いてください。
