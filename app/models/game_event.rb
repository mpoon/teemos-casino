class GameEvent < ActiveRecord::Base
  EXPIRY = 60.seconds

  def expired?
    kind == 'game_start' && DateTime.now > expires_at
  end

  def bet_odds
    # TODO: Calculate odds based on bets
    return {blue: 1, purple: 2} # blue, purple
  end
end
