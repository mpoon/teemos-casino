class User < ActiveRecord::Base
  has_many :bets

  validates :wallet, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  after_commit :wallet_update, :if => ->(r){ previous_changes.include?(:wallet) }

  def update_wallet!(change, reason)
    message = nil
    case reason
    when :bet
    when :bet_canceled
    when :payout
      message = "You won #{change} mushrooms!"
    else
      throw ArgumentError.new("Unknown reason!")
    end

    increment_with_sql!(:wallet, change)
    PusherClient.message(self, "wallet_update", {wallet: self.wallet, message: message})
  end

  # Rails' #increment does not handle concurrency
  # http://apidock.com/rails/ActiveRecord/Base/increment%21#1414-increment-by-sql-for-PG
  def increment_with_sql!(attribute, by = 1)
    raise ArgumentError.new("Invalid attribute: #{attribute}") unless attribute_names.include?(attribute.to_s)
    original_value_sql = "CASE WHEN #{attribute} IS NULL THEN 0 ELSE #{attribute} END"
    self.class.where("id = #{id}").update_all("#{attribute} = #{original_value_sql} + #{by.to_i}")
    reload
  end
end
