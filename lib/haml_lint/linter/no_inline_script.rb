# script タグと javascript フィルタを禁止する。JavaScript は Stimulus のコントローラに書く。
class HamlLint::Linter::NoInlineScript < HamlLint::Linter
  include HamlLint::LinterRegistry

  MESSAGE = 'インラインの JavaScript は使わず、Stimulus のコントローラに書いてください。'.freeze
  SCRIPT_FILTERS = %w[javascript coffee coffeescript].freeze

  def visit_tag(node)
    record_lint(node, MESSAGE) if node.tag_name == 'script'
  end

  def visit_filter(node)
    record_lint(node, MESSAGE) if SCRIPT_FILTERS.include?(node.filter_type)
  end
end
