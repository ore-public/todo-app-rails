# style 属性（ヘルパーの style: オプションを含む）、style タグ、CSS のフィルタを禁止する。
# スタイルシートに値を渡すための CSS カスタムプロパティ（style: '--progress: 50%'）だけは許可する。
class HamlLint::Linter::NoInlineStyle < HamlLint::Linter
  include HamlLint::LinterRegistry

  MESSAGE = 'インラインのスタイルは使わず、スタイルシートにクラスを定義してください。値を渡す場合は CSS カスタムプロパティ（--name: value）だけを使ってください。'.freeze
  STYLE_FILTERS = %w[css sass scss less].freeze
  STYLE_ATTRIBUTE = /(?:\A|[\s,{(])['"]?style['"]?\s*(?::|=>|=)\s*(?<value>.*)/m
  STRING_VALUE = /\A(?<quote>["'])(?<content>.*?)\k<quote>/m
  CUSTOM_PROPERTIES = /\A\s*--[\w-]+\s*:[^;]+(?:;\s*--[\w-]+\s*:[^;]+)*;?\s*\z/

  def visit_tag(node)
    return record_lint(node, MESSAGE) if node.tag_name == 'style'

    source = node.attributes_source.values_at(:hash, :html).compact.join(' ')
    match = STYLE_ATTRIBUTE.match(source)
    return unless match
    return if custom_properties_only?(match[:value])

    record_lint(node, MESSAGE)
  end

  def visit_script(node)
    match = STYLE_ATTRIBUTE.match(node.script)
    return unless match
    return if custom_properties_only?(match[:value])

    record_lint(node, MESSAGE)
  end
  alias visit_silent_script visit_script

  def visit_filter(node)
    record_lint(node, MESSAGE) if STYLE_FILTERS.include?(node.filter_type)
  end

  private def custom_properties_only?(value)
    string = STRING_VALUE.match(value.strip)
    !string.nil? && CUSTOM_PROPERTIES.match?(string[:content])
  end
end
