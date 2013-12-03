#!/usr/bin/ruby -w

require 'rubygems'
require 'pg'

class PostgresDirect
  def connect
    @conn = PG.connect(
      :dbname => 'vagrant',
      :user => 'vagrant',
      :password => 'vagrant')
  end

  def addUser(username)
    twitch_id = (0...12).map { (65 + rand(26)).chr }.join
    @conn.exec(
      "INSERT INTO users (twitch_id,wallet,name,created_at,updated_at) VALUES ('#{twitch_id}',9999999,'#{username}','2013-12-01 08:30:16.614 +00:00','2013-12-01 08:30:16.617 +00:00');")
  end

  def disconnect
    @conn.close
  end
end

def main
  p = PostgresDirect.new()
  p.connect
  begin
    for i in 0..100
      p.addUser("test_user_#{i}")
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  ensure
    p.disconnect
  end
end

main
