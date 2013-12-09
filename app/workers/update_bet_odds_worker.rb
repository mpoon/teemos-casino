class UpdateBetOddsWorker
  include Sidekiq::Worker

  # Update bet odds to client
  def perform(event_id)
    event = GameEvent.find(event_id)
    odds = event.bet_odds

    while Time.now() < event.expires_at
      if event.bet_odds == odds
        logger.info "[UpdateBetOddsWorker] Bet odds did not change"
      else
        odds = event.bet_odds
        logger.info "[UpdateBetOddsWorker] Game id: #{event.game_id} Odds blue: #{odds[:blue]} purple: #{odds[:purple]}"
        PusherClient.global('bet_odds', {
          blue: odds[:blue],
          purple: odds[:purple]
          })
      end
      sleep TeemosCasino::Application.config.bet_odds_update_interval
    end
  end
end
