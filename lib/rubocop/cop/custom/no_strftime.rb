# 日付と時刻の表示には I18n.l を使い、書式はロケールファイルで管理する。
#
# @example
#   # bad
#   todo.due_on.strftime('%m/%d')
#
#   # good
#   l(todo.due_on, format: :short)
class RuboCop::Cop::Custom::NoStrftime < RuboCop::Cop::Base
  MSG = '`strftime` ではなく `I18n.l` を使い、書式はロケールファイルに定義してください。'.freeze
  RESTRICT_ON_SEND = %i[strftime].freeze

  def on_send(node)
    add_offense(node.loc.selector)
  end
  alias on_csend on_send
end
