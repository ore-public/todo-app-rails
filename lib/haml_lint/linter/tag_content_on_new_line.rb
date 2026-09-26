# タグと内容は同じ行に書かず、内容は改行してインデントした行に書く。
#
# @example
#   -# bad
#   %h1 タイトル
#   %p= todo.title
#
#   -# good
#   %h1
#     タイトル
#   %p
#     = todo.title
class HamlLint::Linter::TagContentOnNewLine < HamlLint::Linter
  include HamlLint::LinterRegistry

  MESSAGE = 'タグと内容は同じ行に書かず、内容は次の行に書いてください。'.freeze
  WHITESPACE_MARKERS = %r{\A[<>/]*}

  def visit_tag(node)
    content = node.inline_marker_source.to_s.sub(WHITESPACE_MARKERS, '').strip
    record_lint(node, MESSAGE) unless content.empty?
  end
end
