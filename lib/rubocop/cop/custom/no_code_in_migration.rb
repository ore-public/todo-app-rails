# マイグレーションにはスキーマの変更だけを書く。
# モデルの参照やデータの更新は、モデルの変更で動かなくなったり、新しい環境の構築で実行されなかったりするため。
#
# @example
#   # bad
#   Todo.find_each { |todo| todo.update!(note: '') }
#   execute 'UPDATE todos SET note = ""'
#
#   # good
#   change_column_default :todos, :note, from: nil, to: ''
class RuboCop::Cop::Custom::NoCodeInMigration < RuboCop::Cop::Base
  MSG_CONST = 'マイグレーションでクラス `%<name>s` を使わないでください。スキーマの変更だけを書きます。'.freeze
  MSG_METHOD = 'マイグレーションで `%<method>s` を使わないでください。スキーマの変更だけを書きます。'.freeze
  FORBIDDEN_METHODS = %i[execute exec_query exec_update select_all select_value select_rows reset_column_information up_only].freeze

  def on_send(node)
    receiver = node.receiver
    if receiver.nil?
      add_offense(node.loc.selector, message: format(MSG_METHOD, method: node.method_name)) if FORBIDDEN_METHODS.include?(node.method_name)
    elsif receiver.const_type? && !migration_superclass?(node)
      add_offense(node, message: format(MSG_CONST, name: receiver.const_name))
    end
  end

  private def migration_superclass?(node)
    node.method?(:[]) && node.receiver.const_name == 'ActiveRecord::Migration'
  end
end
