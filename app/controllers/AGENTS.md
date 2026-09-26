# app/controllers の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../../docs/coding_rules.md) にあります。

- **CONTROLLER-02** 1 つのコントローラは 1 つの関心事だけを扱う。
  - 例: todo の完了は `TodosController` のアクションではなく `Todos::CompletionsController` にする。
  - ネストしたリソースのコントローラは `Todos::ApplicationController` を継承し、親のリソースを `before_action` で探す。
- **CONTROLLER-03** 業務の処理はモデルに書き、コントローラはモデルを呼ぶだけにする。ビューのためだけの変数をコントローラで作らない。
- **CONTROLLER-04** 複数のアクションで共通の処理は `before_action` にまとめる。
- **CONTROLLER-08** 例外を握りつぶさない。想定している例外だけを `rescue` し、それ以外は外に伝える。
- **CONTROLLER-09** 想定していないアクセスは例外にする。
  - 例: Turbo Frame に読み込む前提の画面に直接アクセスされたら、`ActionController::BadRequest` を発生させる。
- **CONTROLLER-10** HTML と Turbo Stream は、同じアクションの `respond_to` で返す。
- **CONTROLLER-11** 認可はコントローラで判定し（`head :forbidden unless ...`）、権限の意味はモデルのメソッドに定義する。
