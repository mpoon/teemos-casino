#!/usr/bin/ruby -w

game_time = (ARGV[0] || 60).to_i
sleep_time = (ARGV[1] || 5).to_i


while true do
  game_id = rand(10000)
  puts `curl -X POST -d 'game_id=#{game_id}' 'http://localhost:3000/api/game_events/start'`
  sleep(game_time)
  puts `curl -X POST -d 'game_id=#{game_id}&winner=purple' 'http://localhost:3000/api/game_events/end'`
  sleep(sleep_time)
end
