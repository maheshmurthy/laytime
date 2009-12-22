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

ActiveRecord::Schema.define(:version => 20091221230328) do

  create_table "accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cp_details", :force => true do |t|
    t.string   "partner"
    t.string   "cpName"
    t.integer  "number"
    t.string   "vessel"
    t.string   "from"
    t.string   "to"
    t.string   "details"
    t.text     "remarks"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ports_to_calculate"
    t.string   "once_on_demurrage"
    t.integer  "user_id"
  end

  create_table "facts", :force => true do |t|
    t.datetime "from"
    t.datetime "to"
    t.string   "timeToCount"
    t.float    "val"
    t.string   "remarks"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "port_detail_id"
  end

  create_table "informative_entries", :force => true do |t|
    t.datetime "entrydate"
    t.string   "remarks"
    t.integer  "port_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "port_details", :force => true do |t|
    t.string   "operation"
    t.string   "location"
    t.string   "cargo"
    t.float    "quantity"
    t.string   "description"
    t.string   "allowanceType"
    t.float    "allowance"
    t.float    "demurrage"
    t.float    "despatch"
    t.integer  "cp_detail_id"
    t.string   "calculation_type"
    t.string   "calculation_time_saved"
    t.float    "commission_pct"
    t.datetime "pre_advise_date"
    t.datetime "time_start"
    t.datetime "time_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_cards", :force => true do |t|
    t.integer  "cp_detail_id"
    t.integer  "loading_avail_id"
    t.integer  "discharging_avail_id"
    t.integer  "loading_used_id"
    t.integer  "discharging_used_id"
    t.decimal  "loading_amount",       :precision => 10, :scale => 2
    t.decimal  "discharging_amount",   :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "time_infos", :force => true do |t|
    t.integer  "days"
    t.integer  "hours"
    t.integer  "mins"
    t.string   "time_info_type"
    t.integer  "port_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "perishable_token"
    t.integer  "account_id"
  end

end
