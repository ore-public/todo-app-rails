require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoCounterCache, :config do
  it 'counter_cache を違反にする' do
    expect_offense(<<~RUBY)
      belongs_to :user, inverse_of: :todos, counter_cache: true
                                            ^^^^^^^^^^^^^^^^^^^ `counter_cache` は使わず、件数は必要な時に集計してください。
    RUBY
  end

  it 'counter_cache のない関連は違反にしない' do
    expect_no_offenses(<<~RUBY)
      belongs_to :user, inverse_of: :todos
    RUBY
  end
end
