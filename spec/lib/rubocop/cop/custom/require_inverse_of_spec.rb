require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::RequireInverseOf, :config do
  it 'inverse_of のない関連を違反にする' do
    expect_offense(<<~RUBY)
      class Todo < ApplicationRecord
        belongs_to :user
        ^^^^^^^^^^ `belongs_to` には `inverse_of` を指定してください。
        has_many :taggings, dependent: :delete_all
        ^^^^^^^^ `has_many` には `inverse_of` を指定してください。
        has_one :completion, dependent: :destroy, validate: true
        ^^^^^^^ `has_one` には `inverse_of` を指定してください。
      end
    RUBY
  end

  it 'inverse_of または through を指定した関連は違反にしない' do
    expect_no_offenses(<<~RUBY)
      class Todo < ApplicationRecord
        belongs_to :user, inverse_of: :todos
        has_many :taggings, dependent: :delete_all, inverse_of: :todo
        has_many :tags, through: :taggings
      end
    RUBY
  end

  it 'レシーバーのある呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      builder.belongs_to :user
    RUBY
  end

  it '文字列のキーで inverse_of を指定しても違反にする' do
    expect_offense(<<~RUBY)
      belongs_to :user, 'inverse_of' => :todos
      ^^^^^^^^^^ `belongs_to` には `inverse_of` を指定してください。
    RUBY
  end
end
