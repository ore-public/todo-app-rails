require 'rails_helper'

RSpec.describe User do
  describe 'バリデーションについて' do
    it 'メールアドレスは前後の空白を除いて小文字で保存する' do
      user = create(:user, email_address: '  Taro@Example.COM ')

      expect(user.email_address).to eq 'taro@example.com'
    end

    it 'メールアドレスは形式が正しく、他のユーザーと重複しない' do
      create(:user, email_address: 'taro@example.com')

      expect(build(:user, email_address: 'hanako@example.com')).to be_valid
      expect(build(:user, email_address: 'not-an-email')).not_to be_valid
      expect(build(:user, email_address: 'TARO@example.com')).not_to be_valid
    end

    it 'パスワードは 8 文字以上' do
      expect(build(:user, password: 'a' * 8)).to be_valid
      expect(build(:user, password: 'a' * 7)).not_to be_valid
    end
  end

  describe '削除について' do
    it 'ユーザーを削除すると、セッション・todo・タグも削除する' do
      user = create(:user)
      user.sessions.create!
      create(:todo, user:, tag_names: ['仕事'])

      user.destroy!

      expect(Session.count).to eq 0
      expect(Todo.count).to eq 0
      expect(Tag.count).to eq 0
    end
  end
end
