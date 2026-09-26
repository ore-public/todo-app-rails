module TodosHelper
  def tag_filter_options(tags, open_todo_counts_by_tag_id)
    options = tags.map { |tag| [t('todos.filters.tag_option', name: tag.name, count: open_todo_counts_by_tag_id.fetch(tag.id, 0)), tag.name] }
    [[t('todos.filters.all_tags'), '']] + options
  end

  def due_badge(todo, today:)
    status = todo.due_status(today:)
    tag.span(class: ['el_dueBadge', "el_dueBadge__#{status || :none}"]) do
      t(status || :later, scope: 'todos.due_badge', date: l(todo.due_on, format: :month_day))
    end
  end
end
