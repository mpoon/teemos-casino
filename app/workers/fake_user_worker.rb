class FakeUserWorker
  include Sidekiq::Worker

  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)

    users = User.where(twitch_id: (STARTING_TWITCH_ID..ENDING_TWITCH_ID).map(&:to_s))
    prng = Random.new

    users.shuffle!.each do |user|
      open_bet.reload
      if open_bet.closed?
        logger.info "Not processing open bet ##{open_bet.id} because it's closed"
        return
      end

      amount = prng.rand(user.wallet + 1)

      bet = Bet.new(open_bet: open_bet, user: user, team: ['blue', 'purple'].sample)

      begin
        Bet.transaction do
          user.lock!
          if user.wallet < amount
            raise
          else
            user.update_wallet!(-amount, :bet)
          end
          bet.amount = amount
          bet.save!
        end
      rescue
        next
      end

      user.bet_count += 1
      user.save

      PusherClient.global('bettor', {
        name: bet.user.name,
        amount: bet.amount,
        team: bet.team,
        game_id: bet.open_bet.game_id,
        bet_id: bet.open_bet.bet_id,
        kind: bet.open_bet.kind
      })

      logger.info "#{user.name} placed bet for $#{bet.amount} on #{bet.team} for open_bet #{open_bet_id}"

      sleep(prng.rand(3))
    end
  end
end
