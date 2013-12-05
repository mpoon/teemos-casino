class Api::BetsController < Api::BaseController
  before_filter :require_auth

  def show
    status = {mode: 'closed', game_id: nil, amount: nil, team: nil, expires: nil}

    game_start = GameEvent.order(created_at: :desc).find_by(kind: 'game_start')

    unless game_start
      render json: status and return
    end

    game_end = GameEvent.find_by(kind: 'game_end', game_id: game_start.game_id)

    if game_end
      render json: status and return
    end

    active_bet = current_user.bets.find_by(game_id: game_start.game_id)
    if active_bet
      status = {mode: 'placed',
        game_id: active_bet.game_id,
        amount: active_bet.amount,
        team: active_bet.team,
        expires: nil
      }
    elsif !game_start.expired?
      status = {mode: 'open',
        game_id: game_start.game_id,
        amount: nil,
        team: nil,
        expires: game_start.expires_at
      }
    end

    render json: status
  end

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
