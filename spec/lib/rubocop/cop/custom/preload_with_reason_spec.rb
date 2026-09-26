require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::PreloadWithReason, :config do
  it '理由のコメントがない preload と eager_load を違反にする' do
    expect_offense(<<~RUBY)
      Todo.preload(:tags)
           ^^^^^^^ `preload` を使う理由を直前の行にコメントで書いてください。基本は `includes` を使います。
      todos&.eager_load(:tags)
             ^^^^^^^^^^ `eager_load` を使う理由を直前の行にコメントで書いてください。基本は `includes` を使います。
    RUBY
  end

  it '直前の行か同じ行に理由のコメントがあれば違反にしない' do
    expect_no_offenses(<<~RUBY)
      # 絞り込みに使う tags と表示する tags を別にするため
      Todo.preload(:tags)
      Todo.eager_load(:tags) # tags の条件で並べ替えるため
    RUBY
  end
end
