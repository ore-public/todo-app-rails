require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::RoutesStandardOnly, :config do
  let(:cop_config) { { 'AllowedPaths' => ['up'] } }

  it 'only のない resources と resource を違反にする' do
    expect_offense(<<~RUBY)
      resources :todos
      ^^^^^^^^^ `resources` には `only:` で使うアクションを指定してください。
      resource :session, param: :token
      ^^^^^^^^ `resource` には `only:` で使うアクションを指定してください。
    RUBY
  end

  it 'except を違反にする' do
    expect_offense(<<~RUBY)
      resources :todos, only: %i[index], except: :show
                                         ^^^^^^^^^^^^^ `except:` ではなく `only:` を使ってください。
    RUBY
  end

  it 'member と collection を違反にする' do
    expect_offense(<<~RUBY)
      resources :todos, only: %i[index] do
        member { patch :complete }
        ^^^^^^ `member` は使わず、リソースに切り出してください。
                 ^^^^^ 個別のルートは定義せず、`resources` / `resource` を使ってください。
        collection { get :search }
        ^^^^^^^^^^ `collection` は使わず、リソースに切り出してください。
                     ^^^ 個別のルートは定義せず、`resources` / `resource` を使ってください。
      end
    RUBY
  end

  it '許可していない個別のルートを違反にする' do
    expect_offense(<<~RUBY)
      get 'todos/search' => 'todos#search'
      ^^^ 個別のルートは定義せず、`resources` / `resource` を使ってください。
      post :archive
      ^^^^ 個別のルートは定義せず、`resources` / `resource` を使ってください。
    RUBY
  end

  it 'only を指定した resources と、許可した個別のルートは違反にしない' do
    expect_no_offenses(<<~RUBY)
      root 'todos#index'
      resources :todos, only: %i[index create] do
        resource :completion, only: %i[create destroy], module: :todos
      end
      get 'up' => 'rails/health#show', as: :rails_health_check
    RUBY
  end

  it 'レシーバーのある呼び出しと、パスを指定しない個別のルートを判定する' do
    expect_offense(<<~RUBY)
      mapper.resources :todos
      get
      ^^^ 個別のルートは定義せず、`resources` / `resource` を使ってください。
      resources :todos, 'only' => %i[index]
      ^^^^^^^^^ `resources` には `only:` で使うアクションを指定してください。
    RUBY
  end
end
