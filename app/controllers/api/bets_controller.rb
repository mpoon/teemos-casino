class Api::BetsController < Api::BaseController
  before_filter :require_auth

  def create
    params.require(:game_id)
    params.require(:team)
    amount = params.require(:amount).to_i

    bet = Bet.new(params.permit([:game_id, :team]))
    bet.user = current_user

    if current_user.wallet < amount
      render json: {error: "You don't have that much money!"}, status: :unprocessable_entity
      return
    end

    Bet.transaction do
      current_user.update!(wallet: current_user.wallet - amount)
      bet.amount = amount
      bet.save!
    end

    # TODO: trigger a job to update betting odds

    render json: {message: "Bet placed!"}
  end
end
