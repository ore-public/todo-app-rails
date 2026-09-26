class CreateTodoCompletions < ActiveRecord::Migration[8.1]
  def change
    create_table :todo_completions do |t|
      t.references :todo, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }

      t.timestamps
    end
  end
end
