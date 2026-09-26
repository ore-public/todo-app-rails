# counter_cache は使わない。件数は必要な時に DB で集計する。
#
# @example
#   # bad
#   belongs_to :user, counter_cache: true
class RuboCop::Cop::Custom::NoCounterCache < RuboCop::Cop::Base
  MSG = '`counter_cache` は使わず、件数は必要な時に集計してください。'.freeze

  def_node_matcher :counter_cache_pair?, '(pair (sym :counter_cache) _)'

  def on_pair(node)
    return unless counter_cache_pair?(node)

    add_offense(node)
  end
end
