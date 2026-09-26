require 'rails_helper'

RSpec.describe PasswordsMailer do
  describe '.reset について' do
    it 'パスワードの再設定ページの URL を送る' do
      user = create(:user, email_address: 'taro@example.com')

      mail = PasswordsMailer.with(user:).reset

      expect(mail.to).to eq ['taro@example.com']
      expect(mail.from).to eq ['no-reply@example.com']
      expect(mail.subject).to eq 'パスワードの再設定'
      expect(mail.text_part.body.decoded).to include('次の URL からパスワードを再設定できます。', '/passwords/', '/edit', 'リンクの有効期限は15分です。')
      expect(mail.html_part.body.decoded).to include('パスワードの再設定ページ</a>からパスワードを再設定できます。')
    end
  end
end
