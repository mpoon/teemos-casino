class GameEvent < ActiveRecord::Base
  EXPIRY = 60.seconds

  def expired?
    kind == 'game_start' && DateTime.now > expires_at
  end
end
