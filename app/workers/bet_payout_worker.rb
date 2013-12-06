class BetPayoutWorker
  include Sidekiq::Worker

  # Pay out bet odds given an game_end event
  def perform(event_id)
    event = GameEvent.find(event_id)
    odds = event.bet_odds

    Bet.where(game_id: event.game_id).each do |bet|
      won = bet.team == event.team
      amount = (odds[event.team.to_sym] * bet.amount).floor

      logger.info "[BetPayoutWorker] Bet won:#{won} for #{bet.amount} on #{bet.team}: #{amount}"

      Bet.transaction do
        if won
          bet.user.update!(wallet: bet.user.wallet + amount)
        end
        bet.destroy!
      end
    end
  end
end
