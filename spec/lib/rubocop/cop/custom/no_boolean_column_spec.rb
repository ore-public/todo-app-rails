require 'rubocop_helper'

RSpec.describe RuboCop::Cop::Custom::NoBooleanColumn, :config do
  it 'boolean カラムの追加を違反にする' do
    expect_offense(<<~RUBY)
      create_table :todos do |t|
        t.boolean :done, null: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 状態は boolean カラムではなく、状態を表すテーブルのレコードで表してください。
        t.column :archived, :boolean
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 状態は boolean カラムではなく、状態を表すテーブルのレコードで表してください。
      end
      add_column :todos, :pinned, :boolean
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 状態は boolean カラムではなく、状態を表すテーブルのレコードで表してください。
    RUBY
  end

  it 'boolean 以外のカラムは違反にしない' do
    expect_no_offenses(<<~RUBY)
      create_table :todos do |t|
        t.string :title, null: false
        t.column :note, :text
      end
      add_column :todos, :due_on, :date
    RUBY
  end
end
