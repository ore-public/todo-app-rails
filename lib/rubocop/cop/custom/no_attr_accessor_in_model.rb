# モデルでは attr_accessor ではなく、型とデフォルト値を指定できる attribute を使う。
#
# @example
#   # bad
#   attr_accessor :text
#
#   # good
#   attribute :text, :string, default: ''
class RuboCop::Cop::Custom::NoAttrAccessorInModel < RuboCop::Cop::Base
  MSG = '`%<method>s` ではなく `attribute` で型とデフォルト値を指定してください。'.freeze
  RESTRICT_ON_SEND = %i[attr_accessor attr_writer].freeze

  def on_send(node)
    return if node.receiver

    add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
  end
end
