# 状態は boolean カラムではなく、状態を表すテーブルのレコードの有無で表す。
#
# @example
#   # bad
#   t.boolean :done
#   add_column :todos, :done, :boolean
#
#   # good
#   create_table :todo_completions do |t|
#     t.references :todo, null: false, foreign_key: true, index: { unique: true }
#   end
class RuboCop::Cop::Custom::NoBooleanColumn < RuboCop::Cop::Base
  MSG = '状態は boolean カラムではなく、状態を表すテーブルのレコードで表してください。'.freeze
  RESTRICT_ON_SEND = %i[boolean column add_column change_column].freeze

  def on_send(node)
    return unless node.method?(:boolean) || boolean_type_argument?(node)

    add_offense(node)
  end

  private def boolean_type_argument?(node)
    node.arguments.any? { |argument| argument.sym_type? && argument.value == :boolean }
  end
end
