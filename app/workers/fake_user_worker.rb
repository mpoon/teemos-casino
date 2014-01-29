class FakeUserWorker
  include Sidekiq::Worker

  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)
    if open_bet.closed?
      logger.info "Not processing open bet ##{open_bet.id} because it's closed"
      return
    end

    users = User.where(twitch_id: (STARTING_TWITCH_ID..ENDING_TWITCH_ID).map(&:to_s))
    prng = Random.new

    users.shuffle!.each do |user|
      if user.wallet <= 0
        next
      end

      bet = Bet.new(open_bet: open_bet, user: user)

      bet.team = ["blue", "purple"].sample
      Bet.transaction do
        bet.amount = prng.rand(user.wallet) +1
        user.update_wallet!(-bet.amount, :bet)
        bet.save!
      end

      user.bet_count += 1
      user.save

      PusherClient.global('bettor', {name: bet.user.name, amount: bet.amount, team: bet.team})
      logger.info "#{user.name} placed bet for $#{bet.amount} on #{bet.team}"

      sleep(prng.rand(5))
    end

  end
end