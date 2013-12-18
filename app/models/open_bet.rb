class OpenBet < ActiveRecord::Base
  include BetPool

  has_many :bets

  validates :state, inclusion: { in: %w(open closed resolved),
    message: "%{value} is not a valid state" }

  EXPIRY = 60.seconds


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
end
