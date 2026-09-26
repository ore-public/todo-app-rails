# app/javascript の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../../docs/coding_rules.md) にあります。

- **JS-10** Stimulus のコントローラは、画面ごとではなく振る舞いごとに作る（`dialog`、`auto-submit`、`hotkey` など）。コントローラを追加したら `controllers/index.js` に登録する。
- **JS-11** 状態は values に持ち、`[name]ValueChanged` で画面に反映する。初期値は values の `default` に書く。
- **JS-12** `connect` は何度呼ばれても同じ結果になるように書く。`connect` で確保したもの（タイマーなど）は `disconnect` で解放する。
- **JS-13** 画面の一部の更新は Turbo Frame と Turbo Stream で行う。Frame の外に移動するリンクには `data-turbo-frame="_top"` を付ける。
- **JS-14** keydown の action にはキーを指定する（`keydown.esc->dialog#close`）。
