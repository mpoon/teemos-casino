class Bet < ActiveRecord::Base
  belongs_to :user

  validates :amount, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }
  validates :team, inclusion: { in: %w(purple blue),
    message: "%{value} is not a valid team" }
  validates_uniqueness_of :game_id, :scope => :user_id
end
