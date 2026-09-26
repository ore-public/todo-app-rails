# ルーティングは resources / resource の標準アクションだけで定義する。
#
# @example
#   # bad
#   resources :todos, except: :show
#   resources :todos do
#     member { patch :complete }
#   end
#   get 'todos/search' => 'todos#search'
#
#   # good
#   resources :todos, only: %i[index create] do
#     resource :completion, only: %i[create destroy], module: :todos
#   end
class RuboCop::Cop::Custom::RoutesStandardOnly < RuboCop::Cop::Base
  MSG_ONLY = '`%<method>s` には `only:` で使うアクションを指定してください。'.freeze
  MSG_EXCEPT = '`except:` ではなく `only:` を使ってください。'.freeze
  MSG_BLOCK = '`%<method>s` は使わず、リソースに切り出してください。'.freeze
  MSG_VERB = '個別のルートは定義せず、`resources` / `resource` を使ってください。'.freeze
  RESOURCE_METHODS = %i[resources resource].freeze
  CUSTOM_BLOCK_METHODS = %i[member collection].freeze
  VERB_METHODS = %i[get post patch put delete match].freeze

  # get 'up' => 'rails/health#show' と get 'up', to: 'rails/health#show' のパス
  def_node_matcher :route_path, '(send nil? _ {(str $_) (hash (pair (str $_) _) ...)} ...)'

  def on_send(node)
    return if node.receiver

    method = node.method_name
    if RESOURCE_METHODS.include?(method)
      check_resource(node)
    elsif CUSTOM_BLOCK_METHODS.include?(method)
      add_offense(node.loc.selector, message: format(MSG_BLOCK, method:))
    elsif VERB_METHODS.include?(method)
      add_offense(node.loc.selector, message: MSG_VERB) unless allowed_path?(node)
    end
  end

  private def check_resource(node)
    keys = option_pairs(node).select { |pair| pair.key.sym_type? }.to_h { |pair| [pair.key.value, pair] }
    add_offense(keys[:except], message: MSG_EXCEPT) if keys.key?(:except)
    add_offense(node.loc.selector, message: format(MSG_ONLY, method: node.method_name)) unless keys.key?(:only)
  end

  private def option_pairs(node)
    options = node.arguments.find(&:hash_type?)
    options ? options.pairs : []
  end

  private def allowed_path?(node)
    cop_config.fetch('AllowedPaths', []).include?(route_path(node).to_s.delete_prefix('/'))
  end
end
