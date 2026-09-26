require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoAttrAccessorInModel, :config do
  it 'attr_accessor と attr_writer を違反にする' do
    expect_offense(<<~RUBY)
      class QuickEntry
        attr_accessor :text
        ^^^^^^^^^^^^^ `attr_accessor` ではなく `attribute` で型とデフォルト値を指定してください。
        attr_writer :today
        ^^^^^^^^^^^ `attr_writer` ではなく `attribute` で型とデフォルト値を指定してください。
      end
    RUBY
  end

  it 'attribute と attr_reader は違反にしない' do
    expect_no_offenses(<<~RUBY)
      class QuickEntry
        attribute :text, :string, default: ''
        attr_reader :todos
      end
    RUBY
  end

  it 'レシーバーのある呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      singleton_class.attr_accessor :cache
    RUBY
  end
end
