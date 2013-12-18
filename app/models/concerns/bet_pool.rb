module BetPool
  extend ActiveSupport::Concern

  HOUSE_CUT = 0.0

  def odds
    bluePool = bets.where(team: 'blue').sum('amount')
    purplePool = bets.where(team: 'purple').sum('amount')
    pool = (1 - HOUSE_CUT) * (purplePool + bluePool)

    if bluePool == 0
      blueMult = 0
    else
      blueMult = (pool / bluePool).round(1)
      # Round to integer if the number is the floating point equivalent
      # (1.0 -> 1)
      blueMult = blueMult.to_i if blueMult.to_i == blueMult
    end

    if purplePool == 0
      purpleMult = 0
    else
      purpleMult = (pool / purplePool).round(1)
      # Round to integer if the number is the floating point equivalent
      # (1.0 -> 1)
      purpleMult = purpleMult.to_i if purpleMult.to_i == purpleMult
    end

    return {
      blue: {mult: blueMult, pool: bluePool},
      purple: {mult: purpleMult, pool: purplePool}
    }
  end
end
