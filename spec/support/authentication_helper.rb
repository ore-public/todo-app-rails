module AuthenticationHelper
  def sign_in_as(user)
    post session_path, params: { email_address: user.email_address, password: user.password }
  end
end

module SystemAuthenticationHelper
  def sign_in_as(user)
    visit new_session_path
    fill_in 'メールアドレス', with: user.email_address
    fill_in 'パスワード', with: user.password
    click_on 'ログイン'
    expect(page).to have_button('ログアウト')
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
  config.include SystemAuthenticationHelper, type: :system
end
