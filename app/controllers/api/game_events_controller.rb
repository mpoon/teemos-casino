require 'net/http'

class Api::GameEventsController < Api::BaseController
  before_action :require_api_key

  def start
    event = GameEvent.create(
      game_id: params.require(:game_id),
      kind: "game_start",
      expires_at: DateTime.now + GameEvent::EXPIRY
    )

    if event.errors.empty?
      PusherClient.global('game_start', {
        game_id: event.game_id,
        expires: event.expires_at.to_i * 1000
      })

      UpdateBetOddsWorker.perform_async(event.id)

      render json: {message: "success"}
    else
      render json: {error: event.errors.first}
    end
  end

  def end
    event = GameEvent.create(
      game_id: params.require(:game_id),
      kind: "game_end",
      team: params.require(:winner)
    )

    # TODO: validate team is valid (in model)

    if event.errors.empty?
      BetPayoutWorker.perform_async(event.id)
      PusherClient.global('game_end', {game_id: event.game_id})

      PlayCommercialWorker.perform_async()

      render json: {message: "success"}
    else
      render json: {error: event.errors.first}
    end
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
