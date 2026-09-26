require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoStrftime, :config do
  it 'strftime を違反にする' do
    expect_offense(<<~RUBY)
      todo.due_on.strftime('%m/%d')
                  ^^^^^^^^ `strftime` ではなく `I18n.l` を使い、書式はロケールファイルに定義してください。
      todo.due_on&.strftime('%m/%d')
                   ^^^^^^^^ `strftime` ではなく `I18n.l` を使い、書式はロケールファイルに定義してください。
    RUBY
  end

  it 'I18n.l は違反にしない' do
    expect_no_offenses(<<~RUBY)
      I18n.l(todo.due_on, format: :short)
    RUBY
  end
end
