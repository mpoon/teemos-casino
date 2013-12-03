#!/usr/bin/ruby -w

game_time = (ARGV[0] || 30).to_i
sleep_time = (ARGV[1] || 5).to_i


while true do
  game_id = rand(10000)
  puts `curl -X POST 'http://localhost:3000/api/v1/gameStart?game_id=#{game_id}'`
  sleep(game_time)
  puts `curl -X POST 'http://localhost:3000/api/v1/gameEnd?game_id=#{game_id}&winner=purple'`
  sleep(sleep_time)
end
