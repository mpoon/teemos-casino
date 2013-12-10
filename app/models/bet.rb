class Bet < ActiveRecord::Base
  belongs_to :user
  belongs_to :open_bet

  validates :amount, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }
  validates :team, inclusion: { in: %w(purple blue),
    message: "%{value} is not a valid team" }
  validates_uniqueness_of :open_bet_id, :scope => :user_id
end
