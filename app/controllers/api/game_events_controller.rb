class Api::GameEventsController < ApplicationController
  def start
    event = GameEvent.create(
      game_id: params.require(:game_id),
      kind: "gameStart"
    )



    if event.errors.empty?
      PusherClient.global('game_start', {game_id: event.game_id})
      render json: {message: "success"}
    else
      render json: {error: event.errors.first}
    end
  end

  def end
    event = GameEvent.create(
      game_id: params.require(:game_id),
      kind: "gameEnd",
      team: params.require(:winner)
    )

    if event.errors.empty?
      PusherClient.global('game_end', {game_id: event.game_id})
      render json: {message: "success"}
    else
      render json: {error: event.errors.first}
    end
  end
end
