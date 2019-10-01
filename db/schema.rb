# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190929072625) do

  create_table "attendances", force: :cascade do |t|
    t.datetime "attendance_time"
    t.datetime "leaving_time"
    t.date "day"
    t.datetime "attendance_time_edit"
    t.datetime "leaving_time_edit"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "authorizer_user_id"
    t.integer "user_id"
    t.string "instructor"
    t.datetime "schedule_end_time"
    t.text "business_processing"
    t.integer "authorizer_user_id_of_attendance"
    t.integer "application_edit_state", default: 0
    t.integer "application_state", default: 0
  end

  create_table "base_points", force: :cascade do |t|
    t.string "name"
    t.integer "attendance_state", default: 0
    t.integer "integer", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "basic_infos", force: :cascade do |t|
    t.datetime "basic_work_hour"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "one_month_attendances", force: :cascade do |t|
    t.integer "application_user_id"
    t.integer "authorizer_user_id"
    t.date "application_date"
    t.integer "application_state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.string "affiliation"
    t.time "design_work_hour"
    t.time "basic_work_hour"
    t.integer "user_id"
    t.string "uid"
    t.time "designated_work_start_hour"
    t.time "designated_work_end_hour"
    t.boolean "superior", default: false
    t.integer "applied_last_time_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
