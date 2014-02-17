class BetPayoutWorker
  include Sidekiq::Worker

  # Pay out bet odds given an game_end event
  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)
    event = GameEvent.find_by(game_id: open_bet.game_id, bet_id: open_bet.bet_id)
    odds = open_bet.odds

    open_bet.bets.each do |bet|
      won = bet.team == event.result
      amount = (odds[event.result.to_sym][:mult] * bet.amount).floor
      user = bet.user

      Bet.transaction do
        user.lock!
        if won
          user.update_bet_streak :win
          user.update_wallet!(amount, :payout)
        else
          user.update_bet_streak :loss
          if user.wallet < user.wallet_minimum
            user.update_wallet!(user.wallet_minimum - user.wallet, :bust)
          end
        end

        user.save!
        bet.destroy!
      end

      logger.info "[BetPayoutWorker] #{user.name} Bet won: #{won} for #{bet.amount} on #{bet.team}: #{amount} for open_bet #{open_bet_id}"
    end

    open_bet.update!(state: :resolved)

    topWealthy = []
    topWealthyUsers = User.order(wallet: :desc).limit(10)
    topWealthyUsers.each do |user|
      topWealthy.push({
        name: user.name,
        amount: user.wallet
      })
    end

    PusherClient.global('season_top', {
      top: topWealthy
    })
  end
end
