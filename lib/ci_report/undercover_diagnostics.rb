require 'json'

# undercover の JSON の出力を、reviewdog が読める rdjson に変換する。
# PR で変更したメソッドやブロックのうち、spec で実行されていない行に reviewdog がコメントを付ける
class CiReport::UndercoverDiagnostics
  def initialize(output)
    # undercover は JSON の後に実行時間の行も出力するので、JSON の部分だけを取り出す
    @warnings = JSON.parse(output[/\{.*\}/m] || '{}').fetch('warnings', [])
  end

  def to_rdjson
    JSON.generate(source: { name: 'undercover' }, diagnostics: @warnings.map { |warning| diagnostic(warning) })
  end

  private def diagnostic(warning)
    lines = warning.fetch('uncovered_lines')
    {
      message: message(warning, lines),
      severity: 'WARNING',
      location: {
        path: warning.fetch('file'),
        range: { start: { line: lines.min || warning.fetch('first_line') }, end: { line: lines.max || warning.fetch('last_line') } }
      }
    }
  end

  private def message(warning, lines)
    parts = ["`#{warning.fetch('node')}`（#{warning.fetch('type')}）を変更しましたが、spec で実行されていない箇所があります。"]
    parts << "実行されていない行: #{lines.join(', ')}" if lines.any?
    parts << "実行されていない条件分岐: #{warning.fetch('uncovered_branches').size} 件" if warning.fetch('uncovered_branches').any?
    parts.join("\n")
  end
end
