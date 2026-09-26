require 'rails_helper'

RSpec.describe 'ユーザー登録' do
  describe 'GET /registration/new' do
    it '登録画面を表示する' do
      get new_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<h1 class="el_pageTitle">', 'ユーザー登録')
    end
  end

  describe 'POST /registration' do
    it 'ユーザーを登録してログインする' do
      post registration_path, params: { user: { email_address: 'taro@example.com', password: 'password123', password_confirmation: 'password123' } }

      expect(response).to redirect_to root_path
      expect(User.sole.email_address).to eq 'taro@example.com'
      expect(User.sole.sessions.count).to eq 1
    end

    it '入力が正しくなければ登録せず、エラーを表示する' do
      post registration_path, params: { user: { email_address: 'taro@example.com', password: 'short', password_confirmation: 'other' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('パスワード（確認）とパスワードの入力が一致しません', 'パスワードは8文字以上で入力してください')
      expect(User.count).to eq 0
    end
  end
end
