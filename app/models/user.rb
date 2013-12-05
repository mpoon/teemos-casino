class User < ActiveRecord::Base
  has_many :bets

  validates :wallet, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  after_commit :wallet_update, :if => ->(r){ previous_changes.include?(:wallet) }

  def wallet_update
    PusherClient.message(self, "wallet_update", {wallet: self.wallet})
  end
end
