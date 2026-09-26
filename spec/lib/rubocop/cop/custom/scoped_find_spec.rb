require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::ScopedFind, :config do
  it 'モデルのクラスから直接探す呼び出しを違反にする' do
    expect_offense(<<~RUBY)
      Todo.find(params[:id])
      ^^^^^^^^^^^^^^^^^^^^^^ `Todo.find` ではなく、ログイン中のユーザーの関連から探してください。
      Tag.find_by(name: params[:tag])
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Tag.find_by` ではなく、ログイン中のユーザーの関連から探してください。
    RUBY
  end

  it 'ログイン中のユーザーの関連から探す呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      Current.user.todos.find(params[:id])
      todos.find_by(id: params[:id])
    RUBY
  end

  it 'レシーバーのない呼び出しは違反にしない' do
    expect_no_offenses(<<~RUBY)
      find(params[:id])
    RUBY
  end
end
