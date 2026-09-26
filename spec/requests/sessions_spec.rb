require 'rails_helper'

RSpec.describe 'ログインとログアウト' do
  let(:user) { create(:user, email_address: 'taro@example.com', password: 'password123') }

  describe 'GET /session/new' do
    it 'ログイン画面を表示する' do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<h1 class="el_pageTitle">', 'ログイン')
    end
  end

  describe 'POST /session' do
    before { user }

    it 'メールアドレスとパスワードが正しければログインし、元の画面に戻る' do
      get todos_path(tag: '仕事')

      post session_path, params: { email_address: 'Taro@Example.com', password: 'password123' }

      expect(response).to redirect_to todos_url(tag: '仕事')
      expect(user.sessions.count).to eq 1
    end

    it 'パスワードが違えばログインしない' do
      post session_path, params: { email_address: user.email_address, password: 'wrong-password' }

      expect(response).to redirect_to new_session_path
      expect(flash[:alert]).to eq 'メールアドレスかパスワードが違います'
      expect(user.sessions.count).to eq 0
    end
  end

  describe 'DELETE /session' do
    it 'ログアウトする' do
      sign_in_as user

      delete session_path

      expect(response).to redirect_to new_session_path
      expect(user.sessions.count).to eq 0
    end
  end
end
