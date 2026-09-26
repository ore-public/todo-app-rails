require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoCodeInMigration, :config do
  it 'クラスの参照とデータを操作するメソッドを違反にする' do
    expect_offense(<<~RUBY)
      class FillNote < ActiveRecord::Migration[8.1]
        def up
          Todo.update_all(note: '')
          ^^^^^^^^^^^^^^^^^^^^^^^^^ マイグレーションでクラス `Todo` を使わないでください。スキーマの変更だけを書きます。
          execute 'UPDATE todos SET note = ""'
          ^^^^^^^ マイグレーションで `execute` を使わないでください。スキーマの変更だけを書きます。
        end
      end
    RUBY
  end

  it 'スキーマの変更は違反にしない' do
    expect_no_offenses(<<~RUBY)
      class CreateTodos < ActiveRecord::Migration[8.1]
        def change
          create_table :todos do |t|
            t.string :title, null: false
          end
          add_index :todos, :title
        end
      end
    RUBY
  end
end
