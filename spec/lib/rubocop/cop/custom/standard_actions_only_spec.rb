require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::StandardActionsOnly, :config do
  it '標準アクション以外の public メソッドを違反にする' do
    expect_offense(<<~RUBY)
      class TodosController < ApplicationController
        def index; end

        def complete; end
            ^^^^^^^^ `complete` は標準アクションではありません。リソースに切り出して 7 つのアクションで表してください。
      end
    RUBY
  end

  it 'メソッドが 1 つだけのクラスでも検査する' do
    expect_offense(<<~RUBY)
      class TodosController < ApplicationController
        def search; end
            ^^^^^^ `search` は標準アクションではありません。リソースに切り出して 7 つのアクションで表してください。
      end
    RUBY
  end

  it 'private と protected のメソッドは違反にしない' do
    expect_no_offenses(<<~RUBY)
      class TodosController < ApplicationController
        def index; end

        private def todo_params; end

        protected

        def set_todo; end
      end
    RUBY
  end

  it '中身のないクラスは違反にしない' do
    expect_no_offenses(<<~RUBY)
      class ApplicationController < ActionController::Base
      end
    RUBY
  end
end
