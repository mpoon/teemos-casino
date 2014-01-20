#!/usr/bin/env ruby
require 'optparse'

options = {}
options[:game_time] = 30
options[:sleep_time] = 15

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
  api_key = `heroku config:get API_KEY`.gsub("\n",'')
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
  sleep(options[:game_time])
  puts "Ending game #{game_id}"
  puts `curl -X POST \
             -H "Authorization: #{api_key}" \
             "http://#{host}/api/game_events/end"\
             -d 'game_id=#{game_id}&winner=purple'`
  sleep(options[:sleep_time])
end
