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

ActiveRecord::Schema.define(:version => 20090909012728) do

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
  end

  create_table "facts", :force => true do |t|
    t.date     "from"
    t.date     "to"
    t.string   "timeToCount"
    t.float    "val"
    t.string   "remarks"
    t.integer  "cp_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "informative_entries", :force => true do |t|
    t.date     "entrydate"
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
    t.date     "pre_advise_date"
    t.date     "time_start"
    t.date     "time_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "time_infos", :force => true do |t|
    t.integer  "days"
    t.integer  "hours"
    t.integer  "mins"
    t.string   "type"
    t.integer  "port_detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
