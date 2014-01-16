class Api::BetsController < Api::BaseController
  before_filter :require_auth

  def show
    status = {mode: 'closed', game_id: nil, amount: nil, team: nil, expires: nil}

    open_bet = OpenBet.where(event: 'game').order(created_at: :desc).limit(1).first
    if !open_bet || open_bet.state != "open"
      render json: status and return
    end


    active_bet = open_bet.bets.find_by(user: current_user)
    if active_bet
      status = {mode: 'placed',
        game_id: open_bet.game_id,
        amount: active_bet.amount,
        team: active_bet.team,
        expires: open_bet.expires_at
      }
    elsif !open_bet.expired?
      status = {mode: 'open',
        game_id: open_bet.game_id,
        amount: nil,
        team: nil,
        expires: open_bet.expires_at
      }
    end

    render json: status
  end

  def create
    params.require(:game_id)
    params.require(:team)
    amount = params.require(:amount).to_i

    open_bet = OpenBet.find_by(game_id: params[:game_id])
    if open_bet.closed?
      render json: {error: "Betting is not open!"}, status: :unprocessable_entity
      return
    end

    bet = Bet.new(open_bet: open_bet, team: params[:team], user: current_user)

    if current_user.wallet < amount
      render json: {error: "You don't have that much money!"}, status: :unprocessable_entity
      return
    end

    Bet.transaction do
      current_user.update_wallet!(-amount, :bet)
      bet.amount = amount
      bet.save!
    end

    PusherClient.global('bettor', {name: bet.user.name, amount: bet.amount, team: bet.team})

    current_user.bet_count += 1
    current_user.save

    render json: {message: "Bet placed!"}
  end
end
