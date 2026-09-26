# コントローラの public メソッドは 7 つの標準アクションだけにする。
# それ以外の操作は、名詞のリソースに切り出したコントローラの標準アクションで表す。
#
# @example
#   # bad
#   class TodosController < ApplicationController
#     def complete; end
#   end
#
#   # good
#   class Todos::CompletionsController < ApplicationController
#     def create; end
#   end
class RuboCop::Cop::Custom::StandardActionsOnly < RuboCop::Cop::Base
  MSG = '`%<name>s` は標準アクションではありません。リソースに切り出して 7 つのアクションで表してください。'.freeze
  STANDARD_ACTIONS = %i[index show new create edit update destroy].freeze
  VISIBILITY_MODIFIERS = %i[private protected].freeze

  def on_class(node)
    each_public_method(node.body) do |def_node|
      next if STANDARD_ACTIONS.include?(def_node.method_name)

      add_offense(def_node.loc.name, message: format(MSG, name: def_node.method_name))
    end
  end

  private def each_public_method(body)
    return unless body

    statements = body.begin_type? ? body.children : [body]
    statements.each do |statement|
      break if bare_visibility_modifier?(statement)

      yield statement if statement.def_type?
    end
  end

  private def bare_visibility_modifier?(node)
    node.send_type? && node.receiver.nil? && VISIBILITY_MODIFIERS.include?(node.method_name) && node.arguments.empty?
  end
end
