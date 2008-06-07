# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "contents", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.text     "summary"
    t.text     "body"
    t.string   "state"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contents", ["type", "published_at"], :name => "index_contents_on_type_and_published_at"
  add_index "contents", ["state", "published_at"], :name => "index_contents_on_state_and_published_at"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",                  :null => false
    t.string  "server_url", :default => "", :null => false
    t.string  "salt",       :default => "", :null => false
  end

  create_table "user_openids", :force => true do |t|
    t.string   "openid_url", :default => "", :null => false
    t.integer  "user_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_openids", ["openid_url"], :name => "index_user_openids_on_openid_url", :unique => true
  add_index "user_openids", ["user_id"], :name => "index_user_openids_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.string   "state",                                   :default => "pending"
    t.string   "role",                                    :default => "subscriber"
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["state", "role"], :name => "index_users_on_state_and_role"

end
