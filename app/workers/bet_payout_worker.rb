class BetPayoutWorker
  include Sidekiq::Worker

  # Pay out bet odds given an game_end event
  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)
    event = GameEvent.find_by(game_id: open_bet.game_id, kind: "game_end")
    odds = open_bet.odds

    open_bet.bets.each do |bet|
      won = bet.team == event.team
      amount = (odds[event.team.to_sym][:mult] * bet.amount).floor
      user = bet.user

      logger.info "[BetPayoutWorker] Bet won:#{won} for #{bet.amount} on #{bet.team}: #{amount}"

      Bet.transaction do
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
    end

    open_bet.update!(state: :resolved)
    
    top = []
    topUsers = User.order(wallet: :desc).limit(10)

    topUsers.each do |user|
      top.push({name: user.name, amount: user.wallet})
    end

    PusherClient.global('season_top', {game_id: event.game_id, top: top})
  end
end
