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

ActiveRecord::Schema[8.0].define(version: 2026_01_02_063011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "course_accesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_accesses_on_course_id"
    t.index ["user_id"], name: "index_course_accesses_on_user_id"
  end

  create_table "course_progresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.float "average_band"
    t.datetime "last_practice_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_progresses_on_course_id"
    t.index ["user_id"], name: "index_course_progresses_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.float "band_min"
    t.float "band_max"
    t.decimal "price"
    t.integer "duration_days"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "video_url"
    t.integer "order_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "course_access_id", null: false
    t.decimal "amount"
    t.string "payment_method"
    t.string "transaction_code"
    t.datetime "paid_at"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_access_id"], name: "index_payments_on_course_access_id"
  end

  create_table "speaking_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.bigint "speaking_topic_id", null: false
    t.string "part"
    t.string "audio_url"
    t.text "transcript"
    t.float "overall_band"
    t.float "fluency_score"
    t.float "lexical_score"
    t.float "grammar_score"
    t.float "pronunciation_score"
    t.text "feedback"
    t.string "graded_by"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_speaking_attempts_on_course_id"
    t.index ["speaking_topic_id"], name: "index_speaking_attempts_on_speaking_topic_id"
    t.index ["user_id"], name: "index_speaking_attempts_on_user_id"
  end

  create_table "speaking_questions", force: :cascade do |t|
    t.bigint "speaking_topic_id", null: false
    t.text "question_text"
    t.text "cue_card"
    t.integer "preparation_time"
    t.integer "speaking_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaking_topic_id"], name: "index_speaking_questions_on_speaking_topic_id"
  end

  create_table "speaking_topics", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title"
    t.string "part"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_speaking_topics_on_course_id"
  end

  create_table "teacher_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "bio"
    t.string "expertise"
    t.integer "experience_years"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_teacher_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "role", default: 2, null: false
    t.string "full_name"
    t.string "email"
    t.string "password_digest"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "course_accesses", "courses"
  add_foreign_key "course_accesses", "users"
  add_foreign_key "course_progresses", "courses"
  add_foreign_key "course_progresses", "users"
  add_foreign_key "lessons", "courses"
  add_foreign_key "payments", "course_accesses"
  add_foreign_key "speaking_attempts", "courses"
  add_foreign_key "speaking_attempts", "speaking_topics"
  add_foreign_key "speaking_attempts", "users"
  add_foreign_key "speaking_questions", "speaking_topics"
  add_foreign_key "speaking_topics", "courses"
  add_foreign_key "teacher_profiles", "users"
end
