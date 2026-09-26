class Todos::CompletionsController < Todos::ApplicationController
  def create
    @todo.complete!
    render_refreshed_todos
  end

  def destroy
    @todo.reopen!
    render_refreshed_todos
  end
end
