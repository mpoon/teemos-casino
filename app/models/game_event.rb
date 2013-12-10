class GameEvent < ActiveRecord::Base
  EXPIRY = 60.seconds
  HOUSE_CUT = 0.0

  def expired?
    kind == 'game_start' && DateTime.now > expires_at
  end

  def bet_odds
    bluePool = Bet.where(game_id: game_id, team: 'blue').sum('amount')
    purplePool = Bet.where(game_id: game_id, team: 'purple').sum('amount')
    pool = (1 - HOUSE_CUT) * (purplePool + bluePool)

    if bluePool == 0
      blueMult = 0
    else
      blueMult = (pool / bluePool).round(2)
    end

    if purplePool == 0
      purpleMult = 0
    else
      purpleMult = (pool / purplePool).round(2)
    end

    return {blue: blueMult, purple: purpleMult} # blue, purple
  end
end
