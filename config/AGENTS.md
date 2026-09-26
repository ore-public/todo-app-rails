# config の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../docs/coding_rules.md) にあります。

## ルーティング（config/routes.rb）

- **ROUTING-02** 動詞の操作は名詞のリソースにする。
  - 例: 完了にする・戻すは `resource :completion, only: %i[create destroy]`、公開するは `resource :publication`。
  - 1 対 1 のリソースは単数形の `resource` にする。
- **ROUTING-03** ネストしたリソースには `module:`（または `scope module:`）を付け、URL とコントローラのディレクトリ構成を合わせる。
