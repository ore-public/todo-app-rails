# コントローラではモデルのクラスから直接レコードを探さず、ログイン中のユーザーの関連から探す。
# 他のユーザーのレコードの ID を指定されても見つからないようにするため。
#
# @example
#   # bad
#   Todo.find(params[:id])
#
#   # good
#   Current.user.todos.find(params[:id])
class RuboCop::Cop::Custom::ScopedFind < RuboCop::Cop::Base
  MSG = '`%<receiver>s.%<method>s` ではなく、ログイン中のユーザーの関連から探してください。'.freeze
  RESTRICT_ON_SEND = %i[find find_by find_by! where find_or_create_by find_or_create_by! find_or_initialize_by].freeze

  def on_send(node)
    receiver = node.receiver
    return unless receiver&.const_type?

    add_offense(node, message: format(MSG, receiver: receiver.const_name, method: node.method_name))
  end
end
