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

ActiveRecord::Schema.define(version: 2019_08_15_141825) do

  create_table "admins", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
  end

  create_table "onboarding_related_objects", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "target_id", limit: 4
    t.string "target_type", limit: 255
    t.integer "onboarding_session_id", limit: 4
    t.index ["onboarding_session_id"], name: "index_onboarding_related_objects_on_onboarding_session_id"
  end

  create_table "onboarding_sessions", force: :cascade do |t|
    t.text "completed_high_level_steps", limit: 65535
    t.string "current_step", limit: 255
    t.integer "owner_id", limit: 4
    t.integer "entity_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "step_data", limit: 65535
    t.string "current_high_level_step", limit: 255
    t.text "onboarder_progress", limit: 65535
    t.string "owner_type", limit: 255
    t.datetime "completed_at"
    t.string "onboarder_prefix", limit: 255
    t.string "name", limit: 255
    t.index ["entity_id"], name: "fk__onboarding_sessions_entity_id"
    t.index ["name"], name: "index_onboarding_sessions_on_name"
    t.index ["owner_id"], name: "fk__onboarding_sessions_admin_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "testings", force: :cascade do |t|
  end

end
