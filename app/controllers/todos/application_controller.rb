class Todos::ApplicationController < ApplicationController
  include TodoFilterable

  before_action :set_todo

  private def set_todo
    @todo = Current.user.todos.find(params.expect(:todo_id))
  end
end
