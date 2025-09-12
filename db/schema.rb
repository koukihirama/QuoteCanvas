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

ActiveRecord::Schema[7.2].define(version: 2025_09_11_081828) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_infos", force: :cascade do |t|
    t.bigint "passage_id", null: false
    t.string "title"
    t.string "author"
    t.date "published_date"
    t.string "isbn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_url"
    t.string "source"
    t.string "source_id"
    t.integer "page_count"
    t.string "publisher"
    t.index ["passage_id"], name: "index_book_infos_on_passage_id", unique: true
  end

  create_table "passage_customizations", force: :cascade do |t|
    t.string "font"
    t.string "color"
    t.string "bg_color"
    t.bigint "passage_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["passage_id"], name: "index_passage_customizations_on_passage_id", unique: true
    t.index ["user_id"], name: "index_passage_customizations_on_user_id"
  end

  create_table "passages", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "bg_color"
    t.string "text_color"
    t.string "font_family"
    t.bigint "user_id", null: false
    t.text "content"
    t.index ["user_id", "created_at"], name: "index_passages_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_passages_on_user_id"
  end

  create_table "thought_logs", force: :cascade do |t|
    t.text "content"
    t.bigint "passage_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["passage_id"], name: "index_thought_logs_on_passage_id"
    t.index ["user_id"], name: "index_thought_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.boolean "show_guide", default: true, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "book_infos", "passages"
  add_foreign_key "passage_customizations", "passages"
  add_foreign_key "passage_customizations", "users"
  add_foreign_key "passages", "users"
  add_foreign_key "thought_logs", "passages"
  add_foreign_key "thought_logs", "users"
end
