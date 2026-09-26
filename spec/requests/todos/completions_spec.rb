require 'rails_helper'

RSpec.describe 'todo の完了' do
  let(:user) { create(:user) }
  let(:turbo_stream) { { 'Accept' => 'text/vnd.turbo-stream.html' } }

  it 'ログインしていない場合はログイン画面に移動する' do
    post todo_completion_path(create(:todo))

    expect(response).to redirect_to new_session_path
  end

  describe 'POST /todos/:todo_id/completion' do
    before { sign_in_as user }

    it 'todo を完了にし、一覧を描画し直す' do
      todo = create(:todo, user:, title: '資料作成')

      post todo_completion_path(todo), headers: turbo_stream

      expect(response).to have_http_status(:ok)
      expect(todo.reload.completed?).to be true
      expect(response.body).to include('target="todo-list"', 'target="todo-filters"')
    end

    it 'Turbo を使わない場合は一覧に移動する' do
      todo = create(:todo, user:)

      post todo_completion_path(todo, tag: '仕事')

      expect(response).to redirect_to todos_path(tag: '仕事')
    end

    it '他のユーザーの todo は見つからない' do
      other_todo = create(:todo)

      post todo_completion_path(other_todo), headers: turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_todo.reload.completed?).to be false
    end
  end

  describe 'DELETE /todos/:todo_id/completion' do
    before { sign_in_as user }

    it 'todo を未完了に戻す' do
      todo = create(:todo, :completed, user:)

      delete todo_completion_path(todo, show_completed: 'true'), headers: turbo_stream

      expect(response).to have_http_status(:ok)
      expect(todo.reload.completed?).to be false
    end

    it '他のユーザーの todo は見つからない' do
      other_todo = create(:todo, :completed)

      delete todo_completion_path(other_todo), headers: turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_todo.reload.completed?).to be true
    end
  end
end
