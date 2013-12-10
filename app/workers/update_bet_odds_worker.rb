class UpdateBetOddsWorker
  include Sidekiq::Worker

  UPDATE_INTERVAL = 1

  # Update bet odds to client
  def perform(event_id)
    event = GameEvent.find(event_id)
    odds = event.bet_odds

    while Time.now() < event.expires_at
      odds = event.bet_odds
      previous_odds ||= odds

      if odds == previous_odds
        logger.info "[UpdateBetOddsWorker] Bet odds did not change"
      else
        previous_odds = odds
        logger.info "[UpdateBetOddsWorker] Game id: #{event.game_id} Odds blue: #{odds[:blue]} purple: #{odds[:purple]}"
        PusherClient.global('bet_odds', {
          blue: odds[:blue],
          purple: odds[:purple]
          })
      end
      sleep UPDATE_INTERVAL
    end
  end
end
