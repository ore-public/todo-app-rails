require 'rails_helper'

RSpec.describe 'ユーザー登録とログイン' do
  it 'ユーザーを登録すると todo の画面を表示し、ログアウトできる' do
    visit new_registration_path
    fill_in 'メールアドレス', with: 'taro@example.com'
    fill_in 'パスワード', with: 'password123'
    fill_in 'パスワード（確認）', with: 'password123'
    click_on '登録'

    expect(page).to have_text('todo はありません')
    click_on 'ログアウト'

    expect(page).to have_css('h1', text: 'ログイン')
  end
end
