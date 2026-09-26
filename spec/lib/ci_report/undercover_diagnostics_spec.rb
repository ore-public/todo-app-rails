require 'rails_helper'

RSpec.describe CiReport::UndercoverDiagnostics do
  describe '#to_rdjson について' do
    let(:diagnostics) { JSON.parse(CiReport::UndercoverDiagnostics.new(output).to_rdjson).fetch('diagnostics') }

    context '実行されていない行がある場合' do
      let(:output) do
        <<~OUTPUT
          {
            "warnings": [
              {
                "node": "due_status", "type": "instance method", "file": "app/models/todo.rb",
                "first_line": 10, "last_line": 20, "coverage": 0.5, "uncovered_lines": [14, 12], "uncovered_branches": []
              }
            ],
            "summary": { "total_warnings": 1, "files_affected": 1 }
          }
          Undercover finished in 0.0294s
        OUTPUT
      end

      it '実行されていない行の範囲にコメントを付ける' do
        expect(diagnostics).to eq [
          {
            'message' => "`due_status`（instance method）を変更しましたが、spec で実行されていない箇所があります。\n実行されていない行: 14, 12",
            'severity' => 'WARNING',
            'location' => { 'path' => 'app/models/todo.rb', 'range' => { 'start' => { 'line' => 12 }, 'end' => { 'line' => 14 } } }
          }
        ]
      end
    end

    context '実行されていないのが条件分岐だけの場合' do
      let(:output) do
        '{ "warnings": [{ "node": "Todo", "type": "class", "file": "app/models/todo.rb", "first_line": 1, "last_line": 30, ' \
          '"coverage": 0.9, "uncovered_lines": [], "uncovered_branches": [[5, 0, 1, 0], [5, 0, 2, 0]] }] }'
      end

      it 'メソッドやブロック全体の範囲にコメントを付ける' do
        expect(diagnostics).to eq [
          {
            'message' => "`Todo`（class）を変更しましたが、spec で実行されていない箇所があります。\n実行されていない条件分岐: 2 件",
            'severity' => 'WARNING',
            'location' => { 'path' => 'app/models/todo.rb', 'range' => { 'start' => { 'line' => 1 }, 'end' => { 'line' => 30 } } }
          }
        ]
      end
    end

    context '指摘がない場合' do
      let(:output) { "undercover: ✅ No coverage is missing in latest changes\n" }

      it '空の一覧を出力する' do
        expect(diagnostics).to eq []
      end
    end
  end
end
