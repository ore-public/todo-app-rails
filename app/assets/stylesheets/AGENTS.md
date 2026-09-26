# app/assets/stylesheets の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../../../docs/coding_rules.md) にあります。

- **CSS-10** Bootstrap のユーティリティクラスを優先して使う。`btn` や `form-control` などの Bootstrap のクラスはビューで付け、スタイルシートで上書きしない。
- **CSS-11** 状態は data 属性や aria 属性のセレクタで表す（`.bl_todoItem[aria-current="true"]`、`.bl_todoItem[data-completed]`）。`__` のバリエーションは、見た目の種類（`el_dueBadge__overdue` など）に使う。
- **CSS-12** ファイルは次のディレクトリに分け、各ディレクトリの `_index.scss` で `@forward` する。
  - `lib`: 変数と mixin（Bootstrap の変数と mixin は `lib/_bootstrap_api.scss`）
  - `layouts`: 画面の骨組み（`ly_`）
  - `blocks`: 部品（`bl_`）
  - `elements`: 最小の要素（`el_`）
- **CSS-13** アニメーションを付けるときは `prefers-reduced-motion` を考慮する。
- **CSS-14** レイアウトは flex と grid で組む。Baseline の Widely available の機能だけを使う。
- **CSS-15** マジックナンバーは変数にする。
