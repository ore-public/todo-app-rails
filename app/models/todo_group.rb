# 一覧で実施日ごとにまとめた todo
class TodoGroup
  RELATIVE_DAY_KEYS = { -1 => :yesterday, 0 => :today, 1 => :tomorrow }.freeze

  attr_reader :date, :todos

  # 実施日の昇順で、実施日のないグループは最後。グループの中は作成順
  def self.group(todos)
    todos.group_by(&:scheduled_on)
         .sort_by { |date, _| [date ? 0 : 1, date || Date.new] }
         .map { |date, grouped_todos| new(date:, todos: grouped_todos.sort_by(&:id)) }
  end

  def initialize(date:, todos:)
    @date = date
    @todos = todos
  end

  def label(today: Date.current)
    return I18n.t('todo_group.unscheduled') if date.nil?

    date_label = I18n.l(date, format: :month_day)
    relative_key = RELATIVE_DAY_KEYS[(date - today).to_i]
    relative_key ? "#{I18n.t(relative_key, scope: 'todo_group.relative_days')} #{date_label}" : date_label
  end

  def past?(today: Date.current)
    date.present? && date < today
  end
end
