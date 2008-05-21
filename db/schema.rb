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

ActiveRecord::Schema.define(:version => 4) do

  create_table "abitants", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "login_by_email_token",      :limit => 40
    t.datetime "activated_at"
    t.integer  "favs",                                    :default => 0
    t.string   "url",                                     :default => ""
    t.string   "name",                                    :default => ""
  end

  create_table "transfers", :force => true do |t|
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.integer  "amount",      :default => 1
    t.datetime "created_at"
    t.string   "description", :default => ""
    t.string   "link"
    t.string   "ip"
    t.datetime "updated_at"
  end

end
