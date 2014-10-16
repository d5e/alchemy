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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141016135231) do

  create_table "blends", force: true do |t|
    t.string   "name"
    t.text     "sensory_tags"
    t.text     "notes"
    t.date     "creation_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dilutions", force: true do |t|
    t.integer "substance_id"
    t.string  "solvent",       limit: 15
    t.float   "concentration", limit: 24
    t.integer "intensity",     limit: 1
  end

  create_table "ingredients", force: true do |t|
    t.integer  "blend_id"
    t.integer  "substance_id"
    t.integer  "dilution_id"
    t.float    "amount",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "substances", force: true do |t|
    t.string   "name"
    t.string   "cas"
    t.text     "alt_names"
    t.text     "sensory_tags"
    t.text     "notes"
    t.text     "dilutions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "ifra_cat_4_limit",                 limit: 24
    t.text     "notes_alt_1"
    t.text     "notes_alt_2"
    t.float    "price_per_quantity",               limit: 24
    t.integer  "price_currency",                   limit: 1
    t.float    "quantity_in_gram_of_raw_material", limit: 24
  end

end
