class BetPayoutWorker
  include Sidekiq::Worker

  # Pay out bet odds given an game_end event
  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)
    event = GameEvent.find_by(game_id: open_bet.game_id, kind: "game_end")
    odds = open_bet.odds

    open_bet.bets.each do |bet|
      won = bet.team == event.team
      amount = (odds[event.team.to_sym] * bet.amount).floor
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
  end
end
