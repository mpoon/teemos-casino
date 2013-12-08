class UpdateBetOddsWorker
  include Sidekiq::Worker

  # Update bet odds to client
  def perform(event_id)
    event = GameEvent.find(event_id)

    while Time.now() < event.expires_at
      odds = event.bet_odds
      logger.info "[UpdateBetOddsWorker] Game id: #{event.game_id} Odds blue: #{odds[:blue]} purple: #{odds[:purple]}"
      PusherClient.global('bet_odds', {
        blue: odds[:blue],
        purple: odds[:purple]
        })
      sleep TeemosCasino::Application.config.bet_odds_update_interval
    end
  end
end
