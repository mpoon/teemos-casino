class User < ActiveRecord::Base
  has_many :bets

  store_accessor :properties,
    :bet_streak,
    :bet_count

  validates :wallet, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  def update_bet_streak(result)
    unless [:win, :loss].include? result
      raise ArgumentError.new("Unknown result #{result}!")
    end

    if result == :win
      self.bet_streak = [bet_streak, 0].max + 1
    else
      self.bet_streak = [bet_streak, 0].min - 1
    end
  end

  def bet_streak=(count)
    super(count.to_i)
  end

  def bet_streak
    super.to_i
  end

  def bet_count=(count)
    super(count.to_i)
  end

  def bet_count
    super.to_i
  end

  def stats
    {
      bet_count: bet_count,
      bet_streak: bet_streak
    }
  end

  # By placing bets, users increase their minimum wallet
  # if they go bankrupt.
  def wallet_minimum
    (bet_count / 5) + 10
  end

  def update_wallet!(change, reason)
    message = nil
    case reason
    when :bet
    when :bet_canceled
    when :payout
      message = "You won #{change} mushrooms!"
    when :bust
      message = "You went bust! Here's #{change} mushrooms to get you back on your feet!"
    else
      raise ArgumentError.new("Unknown reason!")
    end

    User.update_counters(id, wallet: change)
    self.reload
    PusherClient.message(self, "wallet_update", {wallet: self.wallet, message: message})
  end
end
