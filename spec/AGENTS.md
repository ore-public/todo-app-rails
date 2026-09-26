# spec の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../docs/coding_rules.md) にあります。

- **SPEC-05** 期待値は明示的な値で書く（`eq order.price` ではなく `eq 1000`）。
- **SPEC-06** describe は「〜について」、context は「〜の場合」とする。it には具体的な結果を書く。
  - 準備（let、before）、実行、検証の順に書く。
  - データの準備に時間がかかる場合は、複数の検証を 1 つの it にまとめてよい（`aggregate_failures` が有効なので、失敗した検証はすべて表示される）。
- **SPEC-07** FactoryBot は、DB が必要なら `create`、不要なら `build` か `build_stubbed` を使う。一意な値は sequence、よく使うパターンは trait にする。example で注目する値は、example の中で指定する。
- **SPEC-08** controller spec は書かず、request spec を書く。request spec では次を確認する。
  - 全アクションの正常系と異常系
  - ログインしていない場合
  - 他のユーザーのデータにアクセスした場合（404）
  - HTML と Turbo Stream の両方を返すアクションは、両方の応答
- **SPEC-09** system spec では JavaScript の動作だけを確認する（`:js` と `:mobile` を付ける）。`sleep` は使わず、Capybara の待機で待つ。
- **SPEC-10** モックとスタブは、外部の API・時刻・乱数などの境界だけに使う。時刻は `travel_to` で固定する。
- **SPEC-11** 同じ振る舞いを、model spec と request spec のように複数の層で重複して確認しない。
- **SPEC-12** spec を追加するときは、既存の example の後ろに足すのではなく、ファイル全体の構成（describe と context の分け方）を見直す。
