class User < ActiveRecord::Base
  has_many :bets

  validates :wallet, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
end
