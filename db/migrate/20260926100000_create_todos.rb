class CreateTodos < ActiveRecord::Migration[8.1]
  def change
    create_table :todos do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :title, null: false
      t.text :note, null: false, default: ''
      t.date :scheduled_on
      t.date :due_on

      t.timestamps
    end
    add_index :todos, %i[user_id scheduled_on]
  end
end
