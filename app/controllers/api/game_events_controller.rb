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

      uri = URI('https://api.twitch.tv/kraken/channels/teemoscasino/commercial')
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Post.new uri
        request['Authorization'] = "OAuth #{TeemosCasino::Application.config.kraken_commercial_oauth}"
        request['Accept'] = 'application/vnd.twitchtv.v3+json'
        request.set_form_data('length' => '90')
        response = http.request request
      end

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
