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

    if event.errors.empty?
      PusherClient.global('game_end', {game_id: event.game_id})
      render json: {message: "success"}
    else
      render json: {error: event.errors.first}
    end
  end

  private

  def require_api_key
    if headers['Authorization'] != TeemosCasino::Application.config.api_key
      render json: {error: "Missing or wrong API key"}, status: :forbidden
    end
  end
end
