# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_26_100003) do
  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address", default: "", null: false
    t.string "user_agent", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "todo_id", null: false
    t.integer "tag_id", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["todo_id", "tag_id"], name: "index_taggings_on_todo_id_and_tag_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
  end

  create_table "todo_completions", force: :cascade do |t|
    t.integer "todo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["todo_id"], name: "index_todo_completions_on_todo_id", unique: true
  end

  create_table "todos", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "note", default: "", null: false
    t.date "scheduled_on"
    t.date "due_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "scheduled_on"], name: "index_todos_on_user_id_and_scheduled_on"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "taggings", "tags", on_delete: :cascade
  add_foreign_key "taggings", "todos", on_delete: :cascade
  add_foreign_key "tags", "users"
  add_foreign_key "todo_completions", "todos", on_delete: :cascade
  add_foreign_key "todos", "users"
end
