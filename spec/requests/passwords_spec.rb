require 'rails_helper'

RSpec.describe 'パスワードの再設定' do
  let(:user) { create(:user, email_address: 'taro@example.com', password: 'password123') }

  describe 'GET /passwords/new' do
    it '再設定の画面を表示する' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('パスワードの再設定')
    end
  end

  describe 'POST /passwords' do
    it '登録されているメールアドレスに再設定の手順を送る' do
      expect { post passwords_path, params: { email_address: user.email_address } }
        .to have_enqueued_mail(PasswordsMailer, :reset).with(params: { user: }, args: [])

      expect(response).to redirect_to new_session_path
    end

    it '登録されていないメールアドレスには送らず、同じ画面に移動する' do
      expect { post passwords_path, params: { email_address: 'unknown@example.com' } }
        .not_to have_enqueued_mail(PasswordsMailer, :reset)

      expect(response).to redirect_to new_session_path
    end
  end

  describe 'GET /passwords/:token/edit' do
    it '新しいパスワードの入力画面を表示する' do
      get edit_password_path(user.password_reset_token)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('新しいパスワードの設定')
    end

    it 'トークンが正しくなければ再設定の画面に戻す' do
      get edit_password_path('invalid-token')

      expect(response).to redirect_to new_password_path
      expect(flash[:alert]).to eq 'パスワードを再設定するリンクが無効か、有効期限が切れています'
    end
  end

  describe 'PUT /passwords/:token' do
    it 'パスワードを変更し、既存のセッションを消す' do
      user.sessions.create!

      put password_path(user.password_reset_token), params: { password: 'new-password', password_confirmation: 'new-password' }

      expect(response).to redirect_to new_session_path
      expect(user.reload.authenticate('new-password')).to eq user
      expect(user.sessions.count).to eq 0
    end

    it '確認用のパスワードが一致しなければ変更しない' do
      token = user.password_reset_token

      put password_path(token), params: { password: 'new-password', password_confirmation: 'other-password' }

      expect(response).to redirect_to edit_password_path(token)
      expect(flash[:alert]).to eq 'パスワード（確認）とパスワードの入力が一致しません'
      expect(user.reload.authenticate('password123')).to eq user
    end
  end
end
