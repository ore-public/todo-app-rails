class TodosController < ApplicationController
  include TodoFilterable

  before_action :set_todo, only: %i[edit update destroy]
  before_action :require_turbo_frame, only: :edit

  def index; end

  def create
    @quick_entry = QuickEntry.new(user: Current.user, **quick_entry_params)
    saved = @quick_entry.save

    respond_to do |format|
      format.turbo_stream { render status: saved ? :ok : :unprocessable_content }
      format.html { redirect_to todos_path(todo_filter.to_params), alert: @quick_entry.errors.full_messages.to_sentence.presence }
    end
  end

  def edit; end

  def update
    if @todo.update(todo_params)
      render_refreshed_todos
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @todo.destroy!
    render_refreshed_todos
  end

  private def set_todo
    @todo = Current.user.todos.find(params.expect(:id))
  end

  # 編集画面はダイアログの中の Turbo Frame に読み込む前提なので、それ以外のアクセスは受け付けない
  private def require_turbo_frame
    raise ActionController::BadRequest, 'edit is only available in a Turbo Frame' unless turbo_frame_request?
  end

  private def quick_entry_params
    params.expect(quick_entry: [:text]).to_h.symbolize_keys
  end

  private def todo_params
    params.expect(todo: %i[title tag_list scheduled_on due_on note])
  end
end
