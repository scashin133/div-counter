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

ActiveRecord::Schema.define(:version => 20090228201159) do

  create_table "processed_sites", :force => true do |t|
    t.integer  "div_count"
    t.string   "uri"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "compressed_body", :limit => 16777215
  end

  add_index "processed_sites", ["div_count"], :name => "index_processed_sites_on_div_count"

  create_table "queued_sites", :force => true do |t|
    t.string   "state"
    t.string   "uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "user_flag",  :default => false
  end

  add_index "queued_sites", ["state"], :name => "index_queued_sites_on_state"

end
