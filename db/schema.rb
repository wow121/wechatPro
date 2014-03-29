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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20140324023452) do
=======
ActiveRecord::Schema.define(:version => 20140224211804) do
>>>>>>> e8a78ed63dfcec5335a2e33593aa1800ebef3dda

  create_table "messages", :force => true do |t|
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "value"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "sku"
    t.string   "sname"
    t.string   "description"
    t.string   "pic"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

<<<<<<< HEAD
  create_table "messages", :force => true do |t|
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "value"
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
=======
  create_table "user_activity_logs", :force => true do |t|
    t.string   "open_id"
    t.string   "event"
    t.string   "content"
>>>>>>> e8a78ed63dfcec5335a2e33593aa1800ebef3dda
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "subscribe"
    t.string   "openid"
    t.string   "nickname"
    t.string   "sex"
    t.string   "language"
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "headimgurl"
    t.string   "subscribe_time"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "email"
    t.integer  "message_count"
    t.string   "code"
  end

end
