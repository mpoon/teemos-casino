class TeemoBotWorker
  include Sidekiq::Worker

  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)
    if open_bet.closed?
      logger.info "Not processing open bet ##{open_bet.id} because it's closed"
      return
    end

    odds = open_bet.odds

    blue_pool = odds[:blue][:pool]
    purple_pool = odds[:purple][:pool]

    user = User.find_by(twitch_id: TEEMO_BOT_TWITCH_ID)
    user.update!(wallet: 0) # Ensure teemo doesn't accumulate money

    bet = Bet.new(open_bet: open_bet, user: user)

    if !blue_pool.zero? && purple_pool.zero?
      # random bet on purple
      bet.team = "purple"
      bet.amount = bet_amount(blue_pool)
    elsif blue_pool.zero? && !purple_pool.zero?
      # random bet on blue
      bet.team = "blue"
      bet.amount = bet_amount(purple_pool)
    elsif blue_pool.zero? && purple_pool.zero?
      # place random bet on random team
      bet.team = ["blue", "purple"].sample
      bet.amount = bet_amount(MAX_BET / 2)
    else
      logger.info "Both teams have bets placed, not placing"
    end

    if bet.team.present?
      bet.save!
      logger.info "Placed bet for $#{bet.amount} on #{bet.team}"
    end
  end


  MAX_BET = 100
  # Determine the amount to bet on one team
  # based on the pool size of the other team
  def bet_amount(pool)
    mid = [pool, MAX_BET].min

    min = (mid * 0.5).to_i
    max = [(mid * 1.5).to_i, MAX_BET].min

    # bet at least one mushroom
    [1, rand(min..max)].max
  end
end
