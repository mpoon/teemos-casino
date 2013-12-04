class Api::GameEventsController < ApplicationController
  def start
    permitted = params.require(:game_id)
    render json: {message: "saved"} 
  end

  def end
    permitted = params.require(:game_id)
    render json: {message: "TODO"} 
  end
end
