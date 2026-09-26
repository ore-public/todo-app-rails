require 'json'

# SimpleCov が出力する coverage/coverage.json から、PR にコメントするカバレッジの要約を Markdown で作る
class CiReport::CoverageSummary
  Count = Data.define(:covered, :total) do
    def self.of(hits)
      counted = hits.grep(Integer)
      new(covered: counted.count(&:positive?), total: counted.size)
    end

    def +(other)
      Count.new(covered: covered + other.covered, total: total + other.total)
    end

    def to_s
      percent = total.zero? ? 100.0 : covered * 100.0 / total
      format('%<percent>.2f%%（%<covered>d / %<total>d）', percent:, covered:, total:)
    end
  end

  FileCoverage = Data.define(:path, :line_hits, :branches) do
    def group
      path.start_with?('app/') ? path.split('/').first(2).join('/') : path.split('/').first
    end

    def lines = Count.of(line_hits)
    def branch_count = Count.of(branches.map { |branch| branch['coverage'] })

    def missed_lines
      line_hits.each_with_index.filter_map { |hits, index| index + 1 if hits == 0 }
    end

    def missed_branch_lines
      branches.filter_map { |branch| branch['start_line'] if branch['coverage'] == 0 }.uniq
    end

    def fully_covered? = missed_lines.empty? && missed_branch_lines.empty?
  end

  MARKER = '<!-- coverage-summary -->'.freeze

  def initialize(coverage_json)
    @files = coverage_json.fetch('coverage').map do |path, data|
      FileCoverage.new(path:, line_hits: data.fetch('lines'), branches: data.fetch('branches', []))
    end
  end

  def to_markdown
    [MARKER, '## カバレッジ', '', *totals_table, '', *missed_section].join("\n")
  end

  private def totals_table
    rows = [['**全体**', @files]] + @files.group_by(&:group).sort.map { |group, files| [group, files] }
    [
      '| 対象 | 行 | 条件分岐 |',
      '|---|---|---|',
      *rows.map { |name, files| "| #{name} | #{files.sum(Count.new(0, 0), &:lines)} | #{files.sum(Count.new(0, 0), &:branch_count)} |" }
    ]
  end

  private def missed_section
    missed_files = @files.reject(&:fully_covered?)
    return ['すべての行と条件分岐が spec で実行されています。'] if missed_files.empty?

    ['<details>', "<summary>spec で実行されていない箇所があるファイル（#{missed_files.size} 件）</summary>", '', *missed_table(missed_files), '', '</details>']
  end

  private def missed_table(files)
    [
      '| ファイル | 行 | 条件分岐がある行 |',
      '|---|---|---|',
      *files.map { |file| "| #{file.path} | #{file.missed_lines.join(', ')} | #{file.missed_branch_lines.join(', ')} |" }
    ]
  end
end
