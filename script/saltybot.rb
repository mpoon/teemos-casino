#!/usr/bin/env ruby
require 'optparse'

options = {}
options[:game_time] = 30
options[:sidebet_time] = 10
options[:sleep_time] = 15

sidebet_types = ['baron_kill', 'dragon_kill', 'turret_kill', 'player_death']

OptionParser.new do |opts|
  opts.banner = "Usage: saltybot.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  env_list = ['development', 'production']
  opts.on("-e", "--environment [ENV]", env_list, "Set environment") do |v|
    options[:environment] = v
  end

  opts.on("-g", "--game-time [DEC]", OptionParser::DecimalInteger, "Game Time") do |v|
    options[:game_time] = v
  end
end.parse!

if options[:environment] == 'production'
  host = "www.teemoscasino.com"
  api_key = `heroku config:get API_KEY --app teemos-casino`.gsub("\n",'')
else
  host = "localhost:3000"
  api_key = ""
end

while true do
  game_id = rand(10000)
  puts "Starting game #{game_id}"
  puts `curl -X POST \
             'http://#{host}/api/game_events/start' \
             -H 'Authorization: #{api_key}' \
             -d 'game_id=#{game_id}'`
  for i in 0..(options[:game_time] / options[:sidebet_time] - 1)
    sleep(options[:sidebet_time])
    puts "Open side bet"
    puts `curl -X POST \
              'http://#{host}/api/game_events/open_sidebet' \
              -H 'Authorization: #{api_key}' \
              -d 'game_id=#{game_id}&kind=#{sidebet_types[i % 4]}'`
    sleep(options[:sidebet_time])
    puts "Close side bet"
    puts `curl -X POST \
              'http://#{host}/api/game_events/close_sidebet' \
              -H 'Authorization: #{api_key}' \
              -d 'game_id=#{game_id}&kind=#{sidebet_types[i % 4]}&winner=purple'`
  end
  sleep(options[:sidebet_time])
  puts "Ending game #{game_id}"
  puts `curl -X POST \
             -H "Authorization: #{api_key}" \
             "http://#{host}/api/game_events/end"\
             -d 'game_id=#{game_id}&winner=purple'`
  sleep(options[:sleep_time])
end
