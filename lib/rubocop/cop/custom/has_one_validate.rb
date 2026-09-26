# has_one には validate オプションを明示する。
# 省略すると関連先のバリデーションが実行されず、不正なレコードが保存されることに気付きにくいため。
#
# @example
#   # bad
#   has_one :completion, dependent: :destroy
#
#   # good
#   has_one :completion, dependent: :destroy, validate: true
class RuboCop::Cop::Custom::HasOneValidate < RuboCop::Cop::Base
  MSG = '`has_one` には `validate` オプションを指定してください。'.freeze
  RESTRICT_ON_SEND = %i[has_one].freeze
  EXEMPT_OPTIONS = %i[validate through].freeze

  def on_send(node)
    return if node.receiver

    options = node.arguments.find(&:hash_type?)
    keys = options ? options.pairs.map { |pair| pair.key.value if pair.key.sym_type? } : []
    return if keys.intersect?(EXEMPT_OPTIONS)

    add_offense(node.loc.selector)
  end
end
