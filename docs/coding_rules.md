# コーディング規約とチェック方法

このアプリのコーディング規約と、それぞれをどう確認するかの一覧です。

- **ツール**: CI（`bin/ci` と GitHub Actions）で自動的に検査します。違反があると CI が失敗します。
- **AI 指示**: ツールで検査できない規約です。書いてある `AGENTS.md` を、AI エージェントがコードを書くときとレビューするときに読みます。人がレビューするときも同じ規約で確認します。

チェック方法の書き方は次のとおりです。`spec/docs/coding_rules_spec.rb` が、ここに書いたルールが設定で有効になっていること、AI 指示の ID が `AGENTS.md` にあることを検査します。

| 書き方 | 意味 |
|---|---|
| `RuboCop: 名前` | `.rubocop.yml` の cop。`Custom/` は `lib/rubocop/cop/custom/` の独自 cop |
| `haml-lint: 名前` | `.haml-lint.yml` の linter。独自 linter は `lib/haml_lint/linter/` |
| `ESLint: 名前` | `eslint.config.js` のルール |
| `stylelint: 名前` | `stylelint.config.js` のルール |
| `AI: パス` | そのパスの `AGENTS.md` に書いた規約 |
| `その他: 説明` | 上以外のツールや spec による検査 |

## 共通

| ID | 規約 | チェック方法 |
|---|---|---|
| COMMON-01 | リッチなドメインモデル、Skinny Controller、CRUD のルーティングを基本にする | AI: AGENTS.md |
| COMMON-02 | 抽象化は、その価値を説明できるときだけ行う | AI: AGENTS.md |
| COMMON-03 | 名前は具体的で、肯定形のドメインの言葉にする。単独で意味が通り、重複を含まない名前にする | AI: AGENTS.md |
| COMMON-04 | コメントには、コードから読み取れない意図・仕様・トレードオフだけを書く | AI: AGENTS.md |
| COMMON-05 | private メソッドは `private def` で定義する | RuboCop: Style/AccessModifierDeclarations |
| COMMON-06 | 文字列の結合は `+` ではなく式展開で書く | RuboCop: Style/StringConcatenation |
| COMMON-07 | クラスとモジュールはネストせず `::` でつなぐ | RuboCop: Style/ClassAndModuleChildren |
| COMMON-08 | 真偽値を返すメソッドは `?` で終わる名前にする | RuboCop: Naming/PredicateMethod |
| COMMON-09 | `send` と `eval` は使わない（spec は除く） | RuboCop: Style/Send, RuboCop: Security/Eval |
| COMMON-10 | 一意なキーのカラムは、外部キーと区別するため `xxx_id` ではなく `xxx_key` と名付ける | AI: AGENTS.md |

## モデル

| ID | 規約 | チェック方法 |
|---|---|---|
| MODEL-01 | クラスの中は、include、定数、属性、バリデーション、関連、コールバック、scope、クラスメソッド、インスタンスメソッド、private メソッドの順に書く | RuboCop: Layout/ClassStructure |
| MODEL-02 | クラスメソッドは `def self.` で定義する | RuboCop: Style/ClassMethodsDefinitions |
| MODEL-03 | 属性は `attr_accessor` ではなく `attribute` で、型とデフォルト値を付けて定義する | RuboCop: Custom/NoAttrAccessorInModel |
| MODEL-04 | 関連には `inverse_of` を指定する | RuboCop: Custom/RequireInverseOf |
| MODEL-05 | `has_one` には `validate` を指定する | RuboCop: Custom/HasOneValidate |
| MODEL-06 | `has_many` と `has_one` には `dependent` を指定する。コールバックの要らない中間テーブルは `:delete_all` にする | RuboCop: Rails/HasManyOrHasOneDependent |
| MODEL-07 | 一意性は DB のユニークインデックスで保証する | RuboCop: Rails/UniqueValidationWithoutIndex, その他: database_consistency |
| MODEL-08 | 必ず守る条件は DB の制約で保証し、利用者にエラーを表示する必要があるときだけバリデーションを付ける。DB の制約とバリデーションは食い違わないようにする | その他: database_consistency, AI: app/models/AGENTS.md |
| MODEL-09 | `counter_cache` は使わない | RuboCop: Custom/NoCounterCache |
| MODEL-10 | N+1 クエリを起こさない。関連の先読みは基本的に `includes` を使う | その他: Bullet（request spec と system spec で検出したら失敗） |
| MODEL-11 | `preload` と `eager_load` を使う場合は、理由をコメントに書く | RuboCop: Custom/PreloadWithReason |
| MODEL-12 | 大量のレコードを順に処理するときは `find_each` を使う | RuboCop: Rails/FindEach |
| MODEL-13 | ループの中で `count` や `exists?` を呼ばず、読み込み済みなら `size` や `present?` を使う。集計は DB で行う | AI: app/models/AGENTS.md |
| MODEL-14 | 大量の保存は `insert_all`、値だけ必要なら `pluck`、サブクエリには `select(:id)` を使う。大量のデータから探すときは Hash にして引く | AI: app/models/AGENTS.md |
| MODEL-15 | 状態は boolean カラムではなく、状態を表すテーブルのレコードで表す（例: 完了は `todo_completions`） | RuboCop: Custom/NoBooleanColumn, AI: app/models/AGENTS.md |
| MODEL-16 | 文字列の状態を比較せず、enum などの述語メソッドを使う | AI: app/models/AGENTS.md |
| MODEL-17 | コールバックは準備と後片付けだけに使い、業務の処理を書かない | AI: app/models/AGENTS.md |
| MODEL-18 | `on:` を付けたバリデーションはできるだけ使わない | AI: app/models/AGENTS.md |
| MODEL-19 | 値の整形は `normalizes` で行う | AI: app/models/AGENTS.md |
| MODEL-20 | 1 つのクラスとメソッドは 1 つの役割だけを持つ。今使わない防御的な処理は書かない | AI: app/models/AGENTS.md |
| MODEL-21 | 複数のモデルで共通の振る舞いは concern にする。1 つのモデル専用の concern は `app/models/concerns/<モデル名>/` に置く。private メソッドだけの concern は作らない | AI: app/models/AGENTS.md |
| MODEL-22 | 表示用のクラスや Form オブジェクトなどの PORO も `app/models` に置く。モデルのメソッドで足りる処理を service object にしない | AI: app/models/AGENTS.md |
| MODEL-23 | 関連先のメソッドをそのまま呼ぶだけのメソッドは `delegate` にする | RuboCop: Rails/Delegate |

## コントローラ

| ID | 規約 | チェック方法 |
|---|---|---|
| CONTROLLER-01 | public メソッドは 7 つの標準アクションだけにする。それ以外の操作はリソースに切り出す | RuboCop: Custom/StandardActionsOnly |
| CONTROLLER-02 | 1 つのコントローラは 1 つの関心事だけを扱う。ネストしたリソースのコントローラは `Todos::ApplicationController` のような親を継承する | AI: app/controllers/AGENTS.md |
| CONTROLLER-03 | 業務の処理と、ビューのためだけの変数をコントローラに書かない | AI: app/controllers/AGENTS.md |
| CONTROLLER-04 | 複数のアクションで共通の処理は `before_action` にまとめる | AI: app/controllers/AGENTS.md |
| CONTROLLER-05 | レコードはログイン中のユーザーの関連から探す（`Current.user.todos.find`） | RuboCop: Custom/ScopedFind |
| CONTROLLER-06 | 戻り値で分岐しない保存・削除は `save!` や `destroy!` を使う | RuboCop: Rails/SaveBang |
| CONTROLLER-07 | パラメータは `params.expect` で受け取る | RuboCop: Rails/StrongParametersExpect, その他: brakeman |
| CONTROLLER-08 | 例外を握りつぶさない | RuboCop: Lint/SuppressedException, AI: app/controllers/AGENTS.md |
| CONTROLLER-09 | 想定していないアクセス（Turbo Frame 専用の画面への直接のアクセスなど）は例外にする | AI: app/controllers/AGENTS.md |
| CONTROLLER-10 | HTML と Turbo Stream は同じアクションの `respond_to` で返す | AI: app/controllers/AGENTS.md |
| CONTROLLER-11 | 認可はコントローラで判定し、権限の意味はモデルに定義する | AI: app/controllers/AGENTS.md |
| CONTROLLER-12 | XSS や SQL インジェクションなどの脆弱性を作らない | その他: brakeman |

## ルーティング

| ID | 規約 | チェック方法 |
|---|---|---|
| ROUTING-01 | `resources` と `resource` の標準アクションだけを使う。`only:` を指定し、`except:`、`member`、`collection`、個別のルートは使わない | RuboCop: Custom/RoutesStandardOnly |
| ROUTING-02 | 動詞の操作は名詞のリソースにする（完了にする → `resource :completion`）。1 対 1 のリソースは単数形の `resource` にする | AI: config/AGENTS.md |
| ROUTING-03 | ネストしたリソースは `module:` を付け、URL と同じディレクトリ構成にする | AI: config/AGENTS.md |

## DB とマイグレーション

| ID | 規約 | チェック方法 |
|---|---|---|
| DB-01 | 関連のカラムには外部キーを付け、外部キーには index を貼る | その他: database_consistency |
| DB-02 | カラムは NOT NULL にする。NULL を許すカラムは、理由と一緒に許可リストに書く | その他: spec/db/schema_spec.rb |
| DB-03 | boolean カラムは作らない（MODEL-15） | RuboCop: Custom/NoBooleanColumn |
| DB-04 | マイグレーションにはスキーマの変更だけを書き、モデルやデータの更新を書かない | RuboCop: Custom/NoCodeInMigration |
| DB-05 | テーブルにはタイムスタンプを付ける | RuboCop: Rails/CreateTableWithTimestamps |
| DB-06 | `db/schema.rb` はマイグレーションの結果と一致させる | その他: CI で db:migrate の後に差分がないことを確認 |
| DB-07 | 論理削除はしない | AI: db/AGENTS.md |
| DB-08 | テーブルは役割ごとに分ける | AI: db/AGENTS.md |
| DB-09 | transaction の中で外部の API を呼ばない | AI: db/AGENTS.md |
| DB-10 | 金額は decimal で、小数 2 桁以上にする | AI: db/AGENTS.md |
| DB-11 | 新しい環境は schema から作る。seed は環境の構築時に 1 回だけ実行する前提で書く | AI: db/AGENTS.md |

## ビュー（Haml）

| ID | 規約 | チェック方法 |
|---|---|---|
| VIEW-01 | ビューに業務の処理を書かない | AI: app/views/AGENTS.md |
| VIEW-02 | 日付と時刻は `strftime` ではなく `I18n.l` で表示する | RuboCop: Custom/NoStrftime |
| VIEW-03 | 文言はロケールファイルに書き、不足や未使用のキーを残さない | RuboCop: Rails/I18nLocaleTexts, その他: i18n-tasks |
| VIEW-04 | パーシャルではインスタンス変数を使わず、locals で受け取る | haml-lint: InstanceVariables |
| VIEW-05 | パーシャルの先頭に `-# locals: (...)` を書く | haml-lint: StrictLocals |
| VIEW-06 | インラインのスタイルを書かない。値を渡すための CSS カスタムプロパティだけは許可する | haml-lint: NoInlineStyle |
| VIEW-07 | インラインの JavaScript を書かない | haml-lint: NoInlineScript |
| VIEW-08 | タグと内容は同じ行に書かず、内容は次の行に書く | haml-lint: TagContentOnNewLine |
| VIEW-09 | img には alt を付ける | haml-lint: AltText |
| VIEW-10 | helper でインスタンス変数を使わず、引数で受け取る | RuboCop: Rails/HelperInstanceVariable |
| VIEW-11 | 変数とページのタイトルはファイルの先頭で宣言する | AI: app/views/AGENTS.md |
| VIEW-12 | 小さな部品は helper にする。ループの中で使うパーシャルは helper にすることを検討する | AI: app/views/AGENTS.md |
| VIEW-13 | HTML は文字列の結合ではなくタグヘルパーで組み立てる | RuboCop: Rails/OutputSafety, AI: app/views/AGENTS.md |
| VIEW-14 | 日本語と英数字の間には半角スペースを入れ、英数字は半角で書く | AI: app/views/AGENTS.md |
| VIEW-15 | 要素を隠すときは、`d-none` クラスより `hidden` 属性を使う | AI: app/views/AGENTS.md |

## JavaScript（Stimulus と Turbo）

| ID | 規約 | チェック方法 |
|---|---|---|
| JS-01 | DOM は `querySelector` などで探さず、targets と outlets で参照する | ESLint: no-restricted-properties |
| JS-02 | イベントは `addEventListener` ではなく data-action で受ける（window と document は `@window` と `@document`） | ESLint: no-restricted-properties |
| JS-03 | data 属性は `dataset` ではなく values と Action Parameters で読む | ESLint: no-restricted-properties |
| JS-04 | 既定の動作の抑止は `preventDefault` ではなく action の `:prevent` と `:stop` を使う | ESLint: no-restricted-properties |
| JS-05 | DOM の変化は MutationObserver ではなく `[name]TargetConnected` で受ける | ESLint: no-restricted-syntax |
| JS-06 | クラス名は文字列で書かず、static classes で定義する | ESLint: no-restricted-syntax |
| JS-07 | action のメソッド名は `onClick` のようなイベント名ではなく、`showDialog` のような振る舞いの名前にする | ESLint: no-restricted-syntax |
| JS-08 | 上の規約の例外として生の DOM API を使う場合は、disable コメントに理由を書く | ESLint: eslint-comments/require-description |
| JS-09 | 書式（セミコロンなし、シングルクォート、`===`、camelCase など） | ESLint: @stylistic/semi, ESLint: @stylistic/quotes, ESLint: eqeqeq, ESLint: camelcase |
| JS-10 | コントローラは画面ごとではなく振る舞いごとに作る（`dialog`、`auto-submit` など） | AI: app/javascript/AGENTS.md |
| JS-11 | 状態は values に持ち、`[name]ValueChanged` で宣言的に反映する | AI: app/javascript/AGENTS.md |
| JS-12 | `connect` は何度呼ばれても同じ結果にする。`connect` で確保したものは `disconnect` で解放する | AI: app/javascript/AGENTS.md |
| JS-13 | 画面の一部の更新は Turbo Frame と Turbo Stream で行う | AI: app/javascript/AGENTS.md |
| JS-14 | keydown の action にはキーを指定する（`keydown.esc->dialog#close`） | AI: app/javascript/AGENTS.md |

## スタイルシート（Sass と Bootstrap）

| ID | 規約 | チェック方法 |
|---|---|---|
| CSS-01 | `@import` ではなく `@use` と `@forward` を使う | stylelint: at-rule-disallowed-list |
| CSS-02 | `@extend` と id セレクタは使わない | stylelint: at-rule-disallowed-list, stylelint: selector-max-id |
| CSS-03 | `@media` を直接書かず、Bootstrap の mixin（`media-breakpoint-down` など）を使う | stylelint: at-rule-disallowed-list |
| CSS-04 | クラス名は `bl_`（ブロック）、`el_`（要素）、`ly_`（レイアウト）、`hp_`（ヘルパー）の接頭辞と camelCase で付ける。子要素は `_`、バリエーションは `__` でつなぐ | stylelint: selector-class-pattern |
| CSS-05 | CSS 変数は camelCase で、ローカルな変数は `--クラス名--プロパティ名` にする | stylelint: custom-property-pattern |
| CSS-06 | Sass の変数・mixin・関数は camelCase にし、private な変数は `$_` で始める | stylelint: scss/dollar-variable-pattern, stylelint: scss/at-mixin-pattern |
| CSS-07 | z-index は `lib/_zindex.scss` の変数だけを使う | stylelint: declaration-property-value-allowed-list |
| CSS-08 | `!important` は使わない | stylelint: declaration-no-important |
| CSS-09 | フォーカスの表示を消さない | stylelint: declaration-property-value-disallowed-list |
| CSS-10 | Bootstrap のユーティリティを優先して使い、Bootstrap のクラスはビューで付ける | AI: app/assets/stylesheets/AGENTS.md |
| CSS-11 | 状態は data 属性や aria 属性のセレクタで表す | AI: app/assets/stylesheets/AGENTS.md |
| CSS-12 | ファイルは `lib`、`layouts`、`blocks`、`elements` に分け、各ディレクトリの `_index.scss` で `@forward` する | AI: app/assets/stylesheets/AGENTS.md |
| CSS-13 | `prefers-reduced-motion` を考慮する | AI: app/assets/stylesheets/AGENTS.md |
| CSS-14 | レイアウトは flex と grid で組み、Baseline の Widely available の機能だけを使う | AI: app/assets/stylesheets/AGENTS.md |
| CSS-15 | マジックナンバーは変数にする | AI: app/assets/stylesheets/AGENTS.md |

## テスト（RSpec）

| ID | 規約 | チェック方法 |
|---|---|---|
| SPEC-01 | `let!` は使わず、`let` と `before` を使う | RuboCop: Custom/NoLetBang |
| SPEC-02 | Job は `allow` と `have_received` でモックせず、`have_enqueued_job` で検証する | RuboCop: Custom/ActiveJobMockInSpec |
| SPEC-03 | example の長さとネストの深さを抑える | RuboCop: RSpec/ExampleLength, RuboCop: RSpec/NestedGroups |
| SPEC-04 | コードは行も条件分岐もすべて spec で実行する | その他: SimpleCov（行 100%、条件分岐 95%） |
| SPEC-05 | 期待値は明示的な値で書く（`eq order.price` ではなく `eq 1000`） | AI: spec/AGENTS.md |
| SPEC-06 | describe は「〜について」、context は「〜の場合」とし、it には具体的な結果を書く | AI: spec/AGENTS.md |
| SPEC-07 | DB が必要なら `create`、不要なら `build` か `build_stubbed` を使う。一意な値は sequence、パターンは trait にする | AI: spec/AGENTS.md |
| SPEC-08 | controller spec は書かず request spec を書く。request spec では全アクションの正常系と異常系、未ログイン、他のユーザーのデータへのアクセスを確認する | AI: spec/AGENTS.md |
| SPEC-09 | system spec では JavaScript の動作だけを確認し、`sleep` を使わず Capybara の待機で待つ | AI: spec/AGENTS.md |
| SPEC-10 | モックとスタブは外部の API・時刻・乱数などの境界だけに使う。時刻は `travel_to` で固定する | AI: spec/AGENTS.md |
| SPEC-11 | 同じ振る舞いを複数の層で重複して確認しない | AI: spec/AGENTS.md |
| SPEC-12 | spec を追加するときは、既存の example の後ろに足すのではなく、ファイル全体の構成を見直す | AI: spec/AGENTS.md |

## メールとジョブ

| ID | 規約 | チェック方法 |
|---|---|---|
| JOB-01 | Mailer には `with` で値を渡し、基本は `deliver_later` で送る | AI: AGENTS.md |
| JOB-02 | Mailer と Job には処理を書かず、モデルのメソッドを呼ぶ | AI: AGENTS.md |
| JOB-03 | Job の引数には、レコードではなく ID を渡す | AI: AGENTS.md |

## セキュリティ

| ID | 規約 | チェック方法 |
|---|---|---|
| SECURITY-01 | 脆弱性のある gem と npm パッケージを使わない | その他: bundler-audit, bun audit |
