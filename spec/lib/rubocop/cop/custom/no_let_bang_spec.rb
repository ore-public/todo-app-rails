require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoLetBang, :config do
  it 'let! を違反にする' do
    expect_offense(<<~RUBY)
      let!(:todo) { create(:todo) }
      ^^^^ `let!` ではなく `let` と `before` を使ってください。
    RUBY
  end

  it 'let と before は違反にしない' do
    expect_no_offenses(<<~RUBY)
      let(:todo) { create(:todo) }
      before { todo }
    RUBY
  end

  it 'レシーバーのある呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      context.let!(:todo) { create(:todo) }
    RUBY
  end
end
