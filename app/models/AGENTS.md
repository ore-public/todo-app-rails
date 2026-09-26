# app/models の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../../docs/coding_rules.md) にあります。

- **MODEL-08** 必ず守る条件（一意性、NOT NULL、外部キーなど）は DB の制約で保証する。バリデーションは、利用者にエラーを表示する必要があるときだけ付ける。
- **MODEL-13** ループの中で `count` や `exists?` を呼ばない。読み込み済みの関連には `size` や `present?` を使う。集計は Ruby ではなく DB で行う（`group(...).count` など）。
- **MODEL-14** 大量の保存は `insert_all` を使う。値だけ必要なときは `pluck`、サブクエリには `select(:id)` を使う。大量のデータから探すときは `Array#find` ではなく Hash にして引く（`index_by` など）。
- **MODEL-15** 状態は boolean カラムではなく、状態を表すテーブルのレコードで表す。
  - 例: 完了は `Todo::Completion`（`has_one :completion`）で表し、`scope :open, -> { where.missing(:completion) }` で絞り込む。
- **MODEL-16** 文字列の状態を `==` で比較しない。enum の述語メソッドや `ActiveSupport::StringInquirer` を使う。
- **MODEL-17** コールバックは準備と後片付けだけに使い、業務の処理を書かない。数も最小にする。
- **MODEL-18** `on: :create` のような条件付きのバリデーションはできるだけ使わない。
- **MODEL-19** 値の整形（前後の空白を除く、小文字にするなど）は `normalizes` で行う。
- **MODEL-20** 1 つのクラスとメソッドは 1 つの役割だけを持つ。他のクラスのデータばかり使うメソッドは、そのクラスに移す。今使わない防御的な処理は書かない。
- **MODEL-21** 複数のモデルで共通の振る舞い（通知、公開範囲の判定など）は concern にする。1 つのモデル専用の concern は `app/models/concerns/<モデル名>/` に置く。private メソッドだけの concern は作らず、モデルに書く。
- **MODEL-22** 表示用のクラスや Form オブジェクトなどの PORO も `app/models` に置く（例: `QuickEntry`、`TodoGroup`、`TodoFilter`）。モデルのメソッドで足りる処理を service object にしない。
