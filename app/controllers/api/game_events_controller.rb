require 'net/http'

class Api::GameEventsController < Api::BaseController
  before_action :require_api_key

  def start
    event = GameEvent.create!(
      game_id: params.require(:game_id),
      kind: "game_start"
    )

    open_bet = OpenBet.create!(
      game_id: event.game_id,
      event: "game",
      state: :open,
      expires_at: DateTime.now + OpenBet::EXPIRY
    )

    PusherClient.global('game_start', {
      game_id: event.game_id,
      expires: open_bet.expires_at.to_i * 1000
    })

    BetUpdateWorker.perform_async(open_bet.id)
    TeemoBotWorker.perform_in(15.seconds, open_bet.id)
    FakeUserWorker.perform_in(5.seconds, open_bet.id)

    render json: {message: "success"}
  end

  def end
    event = GameEvent.create!(
      game_id: params.require(:game_id),
      kind: "game_end",
      team: params.require(:winner)
    )

    # TODO: validate team is valid (in model)
    open_bet = OpenBet.find_by(game_id: event.game_id)
    open_bet.update!(state: :closed)

    PusherClient.global('game_end', {game_id: event.game_id})

    BetPayoutWorker.perform_async(open_bet.id)
    PlayCommercialWorker.perform_async()

    render json: {message: "success"}
  end

  private

  def require_api_key
    key = TeemosCasino::Application.config.api_key
    unless key.present?
      logger.info "No API key set; not requiring" and return
    end

    if request.headers['Authorization'] != key
      render json: {error: "Missing or wrong API key"}, status: :forbidden
    end
  end
end
