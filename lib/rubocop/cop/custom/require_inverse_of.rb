# 関連には inverse_of を明示する。
#
# @example
#   # bad
#   has_many :todos, dependent: :destroy
#
#   # good
#   has_many :todos, dependent: :destroy, inverse_of: :user
class RuboCop::Cop::Custom::RequireInverseOf < RuboCop::Cop::Base
  MSG = '`%<method>s` には `inverse_of` を指定してください。'.freeze
  RESTRICT_ON_SEND = %i[belongs_to has_one has_many has_and_belongs_to_many].freeze
  EXEMPT_OPTIONS = %i[inverse_of through].freeze

  def on_send(node)
    return if node.receiver
    return if option_keys(node).intersect?(EXEMPT_OPTIONS)

    add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
  end

  private def option_keys(node)
    options = node.arguments.find(&:hash_type?)
    return [] unless options

    options.pairs.map { |pair| pair.key.value if pair.key.sym_type? }
  end
end
