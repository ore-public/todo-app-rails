require 'rails_helper'

RSpec.describe 'todo の一覧と操作' do
  let(:user) { create(:user) }
  let(:turbo_stream) { { 'Accept' => 'text/vnd.turbo-stream.html' } }
  let(:turbo_frame) { { 'Turbo-Frame' => 'modal' } }

  describe 'ログインしていない場合' do
    it 'ログイン画面に移動する' do
      get todos_path

      expect(response).to redirect_to new_session_path
    end
  end

  describe 'GET /todos' do
    before do
      create(:todo, user:, title: '資料作成', tag_names: ['仕事'])
      create(:todo, user:, title: '牛乳', tag_names: ['買い物'])
      create(:todo, :completed, user:, title: '会議', tag_names: ['仕事'])
      create(:todo, title: '他のユーザーの todo')
      sign_in_as user
    end

    it '未完了の todo と、タグごとの未完了の件数を表示する' do
      get todos_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('資料作成', '牛乳', '#仕事 (1)', '#買い物 (1)')
      expect(response.body).not_to include('会議', '他のユーザーの todo')
    end

    it 'タグと完了済みの表示で絞り込む' do
      get todos_path(tag: '仕事', show_completed: 'true')

      expect(response.body).to include('資料作成', '会議')
      expect(response.body).not_to include('牛乳')
    end
  end

  describe 'POST /todos' do
    before { sign_in_as user }

    context '入力が正しい場合' do
      it 'todo を作り、一覧を描画し直す' do
        post todos_path(tag: '仕事'), params: { quick_entry: { text: '資料作成 #仕事 @2026-10-01' } }, headers: turbo_stream

        expect(response).to have_http_status(:ok)
        expect(user.todos.sole).to have_attributes(title: '資料作成', scheduled_on: Date.new(2026, 10, 1))
        expect(response.body).to include('<turbo-stream action="replace" target="todo-list">', '資料作成')
      end
    end

    context 'タイトルがない場合' do
      it 'todo を作らず、エラーを表示する' do
        post todos_path, params: { quick_entry: { text: '#仕事' } }, headers: turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(user.todos.count).to eq 0
        expect(response.body).to include('<turbo-stream action="update" target="quick-entry-errors">', 'タイトルを入力してください')
        expect(response.body).not_to include('target="todo-list"')
      end
    end

    context 'Turbo を使わない場合' do
      it '一覧に移動する' do
        post todos_path(tag: '仕事'), params: { quick_entry: { text: '#仕事' } }

        expect(response).to redirect_to todos_path(tag: '仕事')
        expect(flash[:alert]).to eq 'タイトルを入力してください'
      end
    end
  end

  describe 'GET /todos/:id/edit' do
    let(:todo) { create(:todo, user:, title: '資料作成', tag_names: %w[仕事 急ぎ]) }

    before { sign_in_as user }

    it 'Turbo Frame の中に編集フォームを表示する' do
      get edit_todo_path(todo, focus: 'tag_list'), headers: turbo_frame

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="modal">', 'value="資料作成"', 'value="仕事 急ぎ"')
    end

    it 'Turbo Frame 以外からのアクセスは受け付けない' do
      get edit_todo_path(todo)

      expect(response).to have_http_status(:bad_request)
    end

    it '他のユーザーの todo は見つからない' do
      get edit_todo_path(create(:todo)), headers: turbo_frame

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /todos/:id' do
    let(:todo) { create(:todo, user:, title: '資料作成', tag_names: ['仕事']) }

    before { sign_in_as user }

    it 'todo を更新し、一覧を描画し直す' do
      patch todo_path(todo), params: { todo: { title: '企画書作成', tag_list: '仕事 急ぎ', scheduled_on: '2026-10-01', due_on: '', note: 'メモ' } }, headers: turbo_stream

      expect(response).to have_http_status(:ok)
      expect(todo.reload).to have_attributes(title: '企画書作成', tag_names: %w[仕事 急ぎ], scheduled_on: Date.new(2026, 10, 1), due_on: nil, note: 'メモ')
      expect(response.body).to include('target="todo-list"', '企画書作成')
    end

    it '入力が正しくなければ、編集フォームにエラーを表示する' do
      # Turbo Frame の中のフォームは、Turbo Stream と HTML のどちらの応答も受け付ける
      patch todo_path(todo), params: { todo: { title: '' } }, headers: { 'Accept' => 'text/vnd.turbo-stream.html, text/html' }.merge(turbo_frame)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('<turbo-frame id="modal">', 'タイトルを入力してください')
      expect(todo.reload.title).to eq '資料作成'
    end

    it 'Turbo を使わない場合は一覧に移動する' do
      patch todo_path(todo, show_completed: 'true'), params: { todo: { title: '企画書作成' } }

      expect(response).to redirect_to todos_path(show_completed: true)
    end

    it '他のユーザーの todo は見つからない' do
      other_todo = create(:todo, title: '他のユーザーの todo')

      patch todo_path(other_todo), params: { todo: { title: '変更' } }, headers: turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(other_todo.reload.title).to eq '他のユーザーの todo'
    end
  end

  describe 'DELETE /todos/:id' do
    before { sign_in_as user }

    it 'todo を削除し、一覧を描画し直す' do
      todo = create(:todo, user:)

      delete todo_path(todo), headers: turbo_stream

      expect(response).to have_http_status(:ok)
      expect(Todo.exists?(todo.id)).to be false
      expect(response.body).to include('target="todo-list"')
    end

    it '他のユーザーの todo は見つからない' do
      other_todo = create(:todo)

      delete todo_path(other_todo), headers: turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(Todo.exists?(other_todo.id)).to be true
    end
  end
end
