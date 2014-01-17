# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(twitch_id: TEEMO_BOT_TWITCH_ID, name: "Teemo")
User.create(twitch_id: 1, name: "Brand", wallet: 10)
User.create(twitch_id: 2, name: "Annie", wallet: 10)
User.create(twitch_id: 3, name: "Twitch", wallet: 10)
User.create(twitch_id: 4, name: "Darius", wallet: 10)
User.create(twitch_id: 5, name: "Karthus", wallet: 10)
User.create(twitch_id: 6, name: "Taric", wallet: 10)
User.create(twitch_id: 7, name: "Sona", wallet: 10)
User.create(twitch_id: 8, name: "Malphite", wallet: 10)
User.create(twitch_id: 9, name: "Riven", wallet: 10)
User.create(twitch_id: 10, name: "Shaco", wallet: 10)
