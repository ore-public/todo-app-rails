class Todos::SchedulesController < Todos::ApplicationController
  ALLOWED_DAYS = [-1, 1].freeze

  def update
    days = params.expect(:days).to_i
    raise ActionController::BadRequest, "days must be one of #{ALLOWED_DAYS}" unless ALLOWED_DAYS.include?(days)

    @todo.reschedule_by!(days)
    render_refreshed_todos
  end
end
