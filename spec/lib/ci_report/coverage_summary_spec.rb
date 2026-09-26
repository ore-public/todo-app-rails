require 'rails_helper'

RSpec.describe CiReport::CoverageSummary do
  describe '#to_markdown について' do
    context 'すべての行と条件分岐が実行されている場合' do
      it '全体とディレクトリごとの割合を表にする' do
        coverage = {
          'coverage' => {
            'app/models/todo.rb' => { 'lines' => [1, nil, 3], 'branches' => [{ 'start_line' => 1, 'coverage' => 1 }] },
            'app/models/tag.rb' => { 'lines' => [2, 'ignored'], 'branches' => [] },
            'lib/ci_report/coverage_summary.rb' => { 'lines' => [1] }
          }
        }

        expect(CiReport::CoverageSummary.new(coverage).to_markdown).to eq <<~MARKDOWN.chomp
          <!-- coverage-summary -->
          ## カバレッジ

          | 対象 | 行 | 条件分岐 |
          |---|---|---|
          | **全体** | 100.00%（4 / 4） | 100.00%（1 / 1） |
          | app/models | 100.00%（3 / 3） | 100.00%（1 / 1） |
          | lib | 100.00%（1 / 1） | 100.00%（0 / 0） |

          すべての行と条件分岐が spec で実行されています。
        MARKDOWN
      end
    end

    context '実行されていない行や条件分岐がある場合' do
      it 'ファイルごとに、実行されていない行と、条件分岐がある行を一覧にする' do
        coverage = {
          'coverage' => {
            'app/models/todo.rb' => {
              'lines' => [1, 0, nil, 0],
              'branches' => [{ 'start_line' => 1, 'coverage' => 0 }, { 'start_line' => 1, 'coverage' => 0 }, { 'start_line' => 4, 'coverage' => 2 }]
            },
            'app/models/tag.rb' => { 'lines' => [1], 'branches' => [] }
          }
        }

        expect(CiReport::CoverageSummary.new(coverage).to_markdown).to end_with <<~MARKDOWN.chomp
          | **全体** | 50.00%（2 / 4） | 33.33%（1 / 3） |
          | app/models | 50.00%（2 / 4） | 33.33%（1 / 3） |

          <details>
          <summary>spec で実行されていない箇所があるファイル（1 件）</summary>

          | ファイル | 行 | 条件分岐がある行 |
          |---|---|---|
          | app/models/todo.rb | 2, 4 | 1 |

          </details>
        MARKDOWN
      end
    end
  end
end
