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

ActiveRecord::Schema.define(version: 20140210051956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "bets", force: true do |t|
    t.integer  "open_bet_id"
    t.integer  "amount"
    t.string   "team"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bets", ["open_bet_id"], name: "index_bets_on_open_bet_id", using: :btree
  add_index "bets", ["user_id"], name: "index_bets_on_user_id", using: :btree

  create_table "game_events", force: true do |t|
    t.integer  "game_id"
    t.string   "kind",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bet_id"
    t.string   "result"
  end

  create_table "open_bets", force: true do |t|
    t.integer  "game_id"
    t.string   "state"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
    t.integer  "bet_id"
  end

  create_table "users", force: true do |t|
    t.string   "twitch_id",               null: false
    t.integer  "wallet",     default: 0,  null: false
    t.string   "name",                    null: false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.hstore   "properties", default: {}
  end

end
