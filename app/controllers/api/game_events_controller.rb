require 'net/http'

class Api::GameEventsController < Api::BaseController
  before_action :require_api_key

  def open_bet
    event = GameEvent.create!(
      game_id: params.require(:game_id),
      bet_id: params.require(:bet_id),
      kind: params.require(:kind)
    )

    open_bet = OpenBet.create!(
      game_id: event.game_id,
      bet_id: event.bet_id,
      kind: event.kind,
      state: :open,
      expires_at: DateTime.now + OpenBet::EXPIRY
    )

    PusherClient.global('bet_open', {
      game_id: event.game_id,
      bet_id: event.bet_id,
      kind: event.kind,
      expires: open_bet.expires_at.to_i * 1000
    })

    BetUpdateWorker.perform_async(open_bet.id)
    FakeUserWorker.perform_async(open_bet.id)
    # Teemobot and FakeUser

    render json: {message: "success"}
  end

  def close_bet
    event = GameEvent.find_by(
      game_id: params.require(:game_id),
      bet_id: params.require(:bet_id),
      kind: params.require(:kind),
    )
    event.update!(result: params.require(:result))

    open_bet = OpenBet.find_by(game_id: event.game_id, bet_id: event.bet_id)
    open_bet.update!(state: :closed)

    PusherClient.global('bet_close', {
      game_id: event.game_id,
      bet_id: event.bet_id,
      kind: event.kind,
      result: event.result
    })

    BetPayoutWorker.perform_async(open_bet.id)
    # PlayCommercialWorker.perform_async()

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
