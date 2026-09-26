# let! は使わない。事前に作るデータは let で定義し、before で参照して作る。
# どのデータが作られるかを example の近くで読めるようにするため。
#
# @example
#   # bad
#   let!(:todo) { create(:todo) }
#
#   # good
#   let(:todo) { create(:todo) }
#   before { todo }
class RuboCop::Cop::Custom::NoLetBang < RuboCop::Cop::Base
  MSG = '`let!` ではなく `let` と `before` を使ってください。'.freeze
  RESTRICT_ON_SEND = %i[let!].freeze

  def on_send(node)
    return if node.receiver

    add_offense(node.loc.selector)
  end
end
