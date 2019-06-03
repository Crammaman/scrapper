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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_30_023743) do

  create_table "localities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "postcode"
    t.string "locality"
    t.string "region"
    t.string "country"
    t.string "sublocality"
  end

  create_table "locations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "postcode"
    t.string "locality"
    t.string "sublocality"
    t.string "region"
    t.string "country"
    t.string "zone"
    t.bigint "carrier_id"
    t.json "carrier_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["carrier_id"], name: "index_locations_on_carrier_id"
  end

  create_table "transit_times", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "carrier_id"
    t.bigint "from_locality_id"
    t.bigint "to_locality_id"
    t.integer "days"
    t.index ["carrier_id"], name: "index_transit_times_on_carrier_id"
    t.index ["from_locality_id"], name: "index_transit_times_on_from_locality_id"
    t.index ["to_locality_id"], name: "index_transit_times_on_to_locality_id"
  end

  create_table "zones", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "code"
    t.bigint "carrier_id"
    t.bigint "locality_id"
    t.index ["carrier_id"], name: "index_zones_on_carrier_id"
    t.index ["locality_id"], name: "index_zones_on_locality_id"
  end

  add_foreign_key "transit_times", "localities", column: "from_locality_id"
  add_foreign_key "transit_times", "localities", column: "to_locality_id"
end
