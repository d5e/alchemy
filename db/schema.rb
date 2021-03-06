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

ActiveRecord::Schema.define(version: 20150714072952) do

  create_table "blends", force: true do |t|
    t.string   "name"
    t.text     "sensory_tags"
    t.text     "notes"
    t.date     "creation_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",        limit: 8
    t.boolean  "locked",                 default: false
    t.boolean  "hidden",                 default: false
    t.integer  "parent_id"
  end

  create_table "blends_families", force: true do |t|
    t.integer "blend_id"
    t.integer "family_id"
  end

  add_index "blends_families", ["blend_id"], name: "index_blends_families_on_blend_id", using: :btree
  add_index "blends_families", ["family_id"], name: "index_blends_families_on_family_id", using: :btree

  create_table "dilutions", force: true do |t|
    t.integer "substance_id"
    t.string  "solvent",       limit: 15
    t.float   "concentration", limit: 24
    t.integer "intensity",     limit: 1
    t.integer "solvent_id"
  end

  create_table "families", force: true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "color",      limit: 8
    t.text     "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "ingredients", force: true do |t|
    t.integer  "blend_id"
    t.integer  "substance_id"
    t.integer  "dilution_id"
    t.float    "amount",       limit: 53
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "highlighted"
  end

  create_table "notes", force: true do |t|
    t.string   "name"
    t.text     "tags"
    t.text     "body"
    t.text     "links"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "olfactive_families", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "color",       limit: 8
    t.string   "color_light", limit: 8
    t.string   "color_dark",  limit: 8
    t.float    "share",       limit: 24
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "olfactive_families_substances", force: true do |t|
    t.integer  "substance_id"
    t.integer  "olfactive_family_id"
    t.integer  "affinity",            limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "solvent_ingredients", force: true do |t|
    t.integer "solvent_id"
    t.integer "ingredient_id"
    t.float   "amount",        limit: 24
  end

  create_table "solvents", force: true do |t|
    t.string   "name",         limit: 32
    t.string   "symbol",       limit: 3
    t.string   "cas",          limit: 12
    t.boolean  "pure"
    t.float    "logP",         limit: 24
    t.integer  "importance",   limit: 2,  default: 0
    t.text     "notes"
    t.float    "price_per_kg", limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "substances", force: true do |t|
    t.string   "name"
    t.string   "cas"
    t.text     "alt_names"
    t.text     "sensory_tags"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "ifra_cat_4_limit",                 limit: 24
    t.text     "notes_alt_1"
    t.text     "notes_alt_2"
    t.float    "price_per_quantity",               limit: 24
    t.string   "price_currency",                   limit: 3
    t.float    "quantity_in_gram_of_raw_material", limit: 24
    t.string   "character",                        limit: 20
    t.float    "vp_mmHg_25C",                      limit: 24
    t.float    "bpC_760mmHg",                      limit: 24
    t.integer  "tenacity_h",                       limit: 2
  end

end
