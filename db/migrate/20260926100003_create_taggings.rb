class CreateTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :taggings do |t|
      t.references :todo, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    add_index :taggings, %i[todo_id tag_id], unique: true
  end
end
