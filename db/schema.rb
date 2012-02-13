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

ActiveRecord::Schema.define(:version => 20120211193239) do

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "mac_address"
    t.string   "client_type"
    t.string   "ip_address"
    t.integer  "site_id"
    t.boolean  "enabled",        :default => true
    t.datetime "last_checkin"
    t.datetime "last_login"
    t.string   "current_status", :default => "available"
    t.string   "current_user"
    t.string   "current_vm"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clients", ["name"], :name => "index_clients_on_name", :unique => true

  create_table "departments", :force => true do |t|
    t.string   "display_name"
    t.string   "short_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.integer  "client_id"
    t.string   "operation"
    t.datetime "login_time"
    t.datetime "logout_time"
    t.string   "user_id"
    t.string   "vm"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logs", ["client_id"], :name => "index_logs_on_client_id"

  create_table "sites", :force => true do |t|
    t.string   "display_name"
    t.string   "short_name"
    t.string   "name_filter"
    t.integer  "department_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",       :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "name"
    t.string   "email"
    t.integer  "department_id"
    t.string   "role"
    t.integer  "logins",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
