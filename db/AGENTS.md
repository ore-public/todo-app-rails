# db の規約

ツールで検査できない規約です。一覧は [docs/coding_rules.md](../docs/coding_rules.md) にあります。

- **DB-07** 論理削除はしない。削除した記録が必要な場合は、削除を記録するテーブルを作る。
- **DB-08** テーブルは役割ごとに分ける（例: `users`、`user_profiles`、`user_credentials`）。
- **DB-09** transaction の中で外部の API を呼ばない。
- **DB-10** 金額は decimal で、小数 2 桁以上にする。integer にすると小数が暗黙に切り捨てられるため。
- **DB-11** 新しい環境は `db:schema:load`（`bin/setup`）で作る。seed は環境の構築時に 1 回だけ実行する前提で書く。
