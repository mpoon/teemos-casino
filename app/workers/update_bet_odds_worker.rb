class UpdateBetOddsWorker
  include Sidekiq::Worker

  UPDATE_INTERVAL = 1.second

  # Update bet odds to client
  def perform(open_bet_id)
    open_bet = OpenBet.find(open_bet_id)

    while !open_bet.expired?
      odds = open_bet.odds
      previous_odds ||= odds

      if odds == previous_odds
        #logger.info "[UpdateBetOddsWorker] Bet odds did not change"
      else
        previous_odds = odds
        logger.info "[UpdateBetOddsWorker] OpenBet id: #{open_bet.id} Odds blue: #{odds[:blue]} purple: #{odds[:purple]}"
        PusherClient.global('bet_odds', {
          blue: odds[:blue],
          purple: odds[:purple]
        })
      end
      sleep UPDATE_INTERVAL
    end
  end
end
