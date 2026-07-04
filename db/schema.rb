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

ActiveRecord::Schema[8.1].define(version: 2026_04_29_125515) do
  create_table "audits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "news_articles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "published_at"
    t.string "query"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "next_id"
    t.bigint "previous_id"
    t.bigint "statusable_id", null: false
    t.string "statusable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "updated_by", null: false
    t.string "value", null: false
    t.index ["next_id"], name: "index_statuses_on_next_id"
    t.index ["previous_id"], name: "index_statuses_on_previous_id"
    t.index ["statusable_type", "statusable_id"], name: "index_statuses_on_statusable"
    t.index ["updated_by"], name: "fk_rails_239f1561e1"
  end

  create_table "tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.datetime "due_date"
    t.integer "priority", default: 0, null: false
    t.bigint "status_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["discarded_at"], name: "index_tasks_on_discarded_at"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["priority"], name: "index_tasks_on_priority"
    t.index ["status_id"], name: "index_tasks_on_status_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "provider", default: "email", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.json "tokens"
    t.string "uid", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "statuses", "statuses", column: "next_id"
  add_foreign_key "statuses", "statuses", column: "previous_id"
  add_foreign_key "statuses", "users", column: "updated_by"
  add_foreign_key "tasks", "statuses"
  add_foreign_key "tasks", "users"
end
