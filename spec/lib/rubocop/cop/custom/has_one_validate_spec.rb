require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::HasOneValidate, :config do
  it 'validate のない has_one を違反にする' do
    expect_offense(<<~RUBY)
      has_one :completion, dependent: :destroy
      ^^^^^^^ `has_one` には `validate` オプションを指定してください。
      has_one :profile
      ^^^^^^^ `has_one` には `validate` オプションを指定してください。
    RUBY
  end

  it 'validate または through を指定した has_one は違反にしない' do
    expect_no_offenses(<<~RUBY)
      has_one :completion, dependent: :destroy, validate: true
      has_one :owner, through: :project
    RUBY
  end

  it 'レシーバーのある呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      builder.has_one :completion
    RUBY
  end

  it '文字列のキーで validate を指定しても違反にする' do
    expect_offense(<<~RUBY)
      has_one :completion, 'validate' => true
      ^^^^^^^ `has_one` には `validate` オプションを指定してください。
    RUBY
  end
end
