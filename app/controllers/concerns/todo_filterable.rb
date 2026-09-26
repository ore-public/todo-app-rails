# 一覧の絞り込み条件を扱う。更新系のアクションは、同じ条件で描画し直した一覧を返す
module TodoFilterable
  extend ActiveSupport::Concern

  included do
    helper_method :todo_filter
  end

  private def todo_filter
    @todo_filter ||= TodoFilter.new(user: Current.user, **params.permit(:tag, :show_completed).to_h.symbolize_keys)
  end

  private def render_refreshed_todos
    respond_to do |format|
      format.turbo_stream { render partial: 'todos/refresh', locals: { filter: todo_filter } }
      format.html { redirect_to todos_path(todo_filter.to_params) }
    end
  end
end
