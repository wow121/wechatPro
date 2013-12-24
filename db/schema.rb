# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131224060250) do

  create_table "merchant_codes", :force => true do |t|
    t.string   "merchant_id"
    t.string   "code"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "merchant_projects", :force => true do |t|
    t.string   "project_name"
    t.string   "project_name_short"
    t.string   "project_intro"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "merchant_id"
    t.string   "code"
  end

  create_table "merchants", :force => true do |t|
    t.string   "user_name"
    t.string   "password"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "corp_name"
    t.string   "loc_name"
    t.string   "office_name"
    t.string   "token"
    t.integer  "admin"
  end

  create_table "photo_logs", :force => true do |t|
    t.string   "upload_type"
    t.string   "user_id"
    t.string   "merchant_id"
    t.string   "photo_id"
    t.string   "file_path"
    t.string   "state"
    t.string   "payment_id"
    t.string   "payment_email"
    t.string   "paid_at"
    t.string   "weixin_url"
    t.string   "weixin_image_path"
    t.text     "description"
    t.integer  "downloads",         :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "photos", :force => true do |t|
    t.string   "upload_type"
    t.string   "user_id"
    t.string   "merchant_id"
    t.string   "photo_id"
    t.string   "file_path"
    t.string   "state"
    t.string   "payment_id"
    t.string   "payment_email"
    t.string   "paid_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "weixin_url"
    t.string   "weixin_image_path"
    t.text     "description"
    t.integer  "downloads",         :default => 0
    t.text     "title"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "weixin_id"
    t.string   "password"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "status"
    t.integer  "photo_count"
    t.string   "context"
  end

end
