# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080830174813) do

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "user_id",    :limit => 11
    t.datetime "created_on"
    t.integer  "snippet_id", :limit => 11
    t.string   "name",                     :default => ""
    t.string   "email",                    :default => ""
  end

  create_table "includes", :force => true do |t|
    t.integer "snippet_id", :limit => 11
    t.integer "user_id",    :limit => 11
    t.integer "parent_id",  :limit => 11
  end

  create_table "invitations", :force => true do |t|
    t.integer "user_id",   :limit => 11
    t.string  "recipient"
    t.string  "key"
  end

  create_table "licenses", :force => true do |t|
    t.string "name"
    t.text   "text"
  end

  create_table "snippets", :force => true do |t|
    t.integer  "user_id",     :limit => 11
    t.string   "method_name"
    t.text     "code"
    t.string   "language"
    t.integer  "version",     :limit => 11, :default => 0
    t.text     "description"
    t.integer  "license_id",  :limit => 11
    t.string   "published"
    t.datetime "created_on"
    t.string   "release"
    t.datetime "last_marker"
    t.integer  "count",       :limit => 11
    t.integer  "total_use",   :limit => 11
    t.integer  "ancestor_id", :limit => 11
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "fullname"
  end

end
