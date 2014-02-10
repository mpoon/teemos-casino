class BetUpdateWorker
  include Sidekiq::Worker

  UPDATE_INTERVAL = 2.seconds

  # Update bet odds to client
  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)

    while !open_bet.expired?
      odds = open_bet.odds
      previous_odds ||= odds

      if odds == previous_odds
        #logger.info "[BetUpdateWorker] Bet odds did not change"
      else
        previous_odds = odds
        logger.info "[BetUpdateWorker] OpenBet id: #{open_bet.id} Odds blue: #{odds[:blue]} purple: #{odds[:purple]}"
        PusherClient.global('bet_update', {
          game_id: open_bet.game_id,
          bet_id: open_bet.bet_id,
          kind: open_bet.kind,
          odds: odds
        })
      end

      sleep UPDATE_INTERVAL
    end
  end
end
