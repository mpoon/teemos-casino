class OpenBet < ActiveRecord::Base
  EXPIRY = 60.seconds
  HOUSE_CUT = 0.0

  has_many :bets

  validates :state, inclusion: { in: %w(open closed resolved),
    message: "%{value} is not a valid state" }

  def state=(new_state)
    super new_state.to_s
  end

  def open?
    !expired? && state == "open"
  end

  def closed?
    !open?
  end

  def expired?
    return false unless expires_at.present?
    DateTime.now > expires_at
  end

  def odds
    bluePool = bets.where(team: 'blue').sum('amount')
    purplePool = bets.where(team: 'purple').sum('amount')
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
