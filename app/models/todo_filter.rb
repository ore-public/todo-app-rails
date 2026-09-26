# 一覧の絞り込み条件。条件は URL のクエリパラメータで受け渡す
class TodoFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user
  attribute :tag, :string, default: ''
  attribute :show_completed, :boolean, default: false

  delegate :open_todo_counts_by_tag_id, to: :user

  def todos
    todos = user.todos.includes(:completion, taggings: :tag).in_schedule_order
    todos = todos.open unless show_completed
    todos = todos.tagged(tag) if tag.present?
    todos
  end

  def groups
    TodoGroup.group(todos)
  end

  def tags
    user.tags.ordered
  end

  # 更新系のリクエストの URL に付けて、応答で同じ条件の一覧を返せるようにする
  def to_params
    { tag: tag.presence, show_completed: show_completed || nil }.compact
  end
end
