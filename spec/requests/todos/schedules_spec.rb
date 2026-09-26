require 'rails_helper'

RSpec.describe '実施日の変更' do
  let(:user) { create(:user) }
  let(:turbo_stream) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

  describe 'PATCH /todos/:todo_id/schedule' do
    before { sign_in_as user }

    it '実施日を 1 日後と 1 日前にずらす' do
      todo = create(:todo, user:, scheduled_on: Date.new(2026, 9, 30))

      patch todo_schedule_path(todo), params: { days: 1 }, headers: turbo_stream
      expect(response).to have_http_status(:ok)
      expect(todo.reload.scheduled_on).to eq Date.new(2026, 10, 1)

      patch todo_schedule_path(todo), params: { days: -1 }, headers: turbo_stream
      expect(todo.reload.scheduled_on).to eq Date.new(2026, 9, 30)
    end

    it '1 日以外のずらし方は受け付けない' do
      todo = create(:todo, user:, scheduled_on: Date.new(2026, 9, 30))

      patch todo_schedule_path(todo), params: { days: 7 }, headers: turbo_stream

      expect(response).to have_http_status(:bad_request)
      expect(todo.reload.scheduled_on).to eq Date.new(2026, 9, 30)
    end

    it '他のユーザーの todo は見つからない' do
      other_todo = create(:todo, scheduled_on: Date.new(2026, 9, 30))

      patch todo_schedule_path(other_todo), params: { days: 1 }, headers: turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_todo.reload.scheduled_on).to eq Date.new(2026, 9, 30)
    end
  end
end
