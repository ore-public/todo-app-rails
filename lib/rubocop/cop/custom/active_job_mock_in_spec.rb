# Job のエンキューは allow / have_received のモックではなく、have_enqueued_job で検証する。
#
# @example
#   # bad
#   allow(ReminderJob).to receive(:perform_later)
#   expect(ReminderJob).to have_received(:perform_later)
#
#   # good
#   expect { todo.remind }.to have_enqueued_job(ReminderJob)
#   expect(ReminderJob).to have_been_enqueued.at(1.hour.from_now)
class RuboCop::Cop::Custom::ActiveJobMockInSpec < RuboCop::Cop::Base
  MSG = 'Job は `allow` / `have_received` でモックせず、`have_enqueued_job` / `have_been_enqueued` で検証してください。'.freeze
  RESTRICT_ON_SEND = %i[to not_to to_not].freeze
  ENQUEUE_METHODS = %i[perform_later perform_now set].freeze

  def_node_matcher :expectation_target, '(send nil? ${:allow :expect} $_)'

  def on_send(node)
    target_method, target = expectation_target(node.receiver)
    return unless target_method && job?(target)

    matcher_method = target_method == :allow ? %i[receive receive_messages receive_message_chain] : %i[have_received]
    return unless enqueue_matcher?(node.first_argument, matcher_method)

    add_offense(node)
  end

  private def job?(node)
    name = case node.type
           when :const then node.const_name
           when :lvar, :ivar then node.children.first.to_s
           when :send then node.method_name.to_s if node.receiver.nil?
           end
    name.to_s.end_with?('Job', '_job')
  end

  private def enqueue_matcher?(node, matcher_methods)
    while node&.send_type?
      return true if matcher_methods.include?(node.method_name) && node.arguments.any? { |argument| enqueue_method?(argument) }

      node = node.receiver
    end
    false
  end

  private def enqueue_method?(argument)
    if argument.hash_type?
      argument.keys.any? { |key| enqueue_method?(key) }
    else
      argument.sym_type? && ENQUEUE_METHODS.include?(argument.value)
    end
  end
end
