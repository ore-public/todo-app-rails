# preload / eager_load を使う場合は、includes では足りない理由をコメントに書く。
#
# @example
#   # bad
#   Todo.preload(:tags)
#
#   # good
#   # tags で絞り込む条件と、表示用に読み込む tags を別にするため preload を使う
#   Todo.preload(:tags)
class RuboCop::Cop::Custom::PreloadWithReason < RuboCop::Cop::Base
  MSG = '`%<method>s` を使う理由を直前の行にコメントで書いてください。基本は `includes` を使います。'.freeze
  RESTRICT_ON_SEND = %i[preload eager_load].freeze

  def on_send(node)
    line = node.loc.selector.line
    return if comment_lines.include?(line) || comment_lines.include?(line - 1)

    add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
  end
  alias on_csend on_send

  private def comment_lines
    @comment_lines ||= processed_source.comments.to_set { |comment| comment.loc.line }
  end
end
