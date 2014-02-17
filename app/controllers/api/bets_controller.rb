class Api::BetsController < Api::BaseController
  before_filter :require_auth

  def status
    status = []

    open_bets = OpenBet.where(state: 'open')

    open_bets.each do |open_bet|
      active_bet = open_bet.bets.find_by(user: current_user)
      if active_bet
        status.push({
          mode: 'placed',
          gameId: open_bet.game_id,
          betId: open_bet.bet_id,
          amount: active_bet.amount,
          team: active_bet.team,
          expires: open_bet.expires_at,
          kind: open_bet.kind
        })
      elsif !open_bet.expired?
        status.push({
          mode: 'open',
          gameId: open_bet.game_id,
          betId: open_bet.bet_id,
          amount: nil,
          team: nil,
          expires: open_bet.expires_at,
          kind: open_bet.kind
        })
      elsif open_bet.expired?
        status.push({
          mode: 'closed',
          gameId: open_bet.game_id,
          betId: open_bet.bet_id,
          amount: nil,
          team: nil,
          expires: open_bet.expires_at,
          kind: open_bet.kind
        })
      end
    end

    if status.empty?
      status.push({
        mode: nil,
        gameId: nil,
        amount: nil,
        team: nil,
        expires: nil,
        betId: nil,
        kind: nil
      })
    end

    render json: status
  end

  def create
    game_id = params.require(:game_id)
    bet_id = params.require(:bet_id)
    kind = params.require(:kind)
    team = params.require(:team)
    amount = params.require(:amount).to_i

    open_bet = OpenBet.find_by(game_id: game_id, bet_id: bet_id)
    if open_bet.closed?
      render json: {error: "Betting is not open!"}, status: :unprocessable_entity
      return
    end

    bet = Bet.new(open_bet: open_bet, team: team, user: current_user)

    begin
      Bet.transaction do
        if current_user.wallet < amount
          raise
        end
        current_user.update_wallet!(-amount, :bet)
        bet.amount = amount
        bet.save!
      end
    rescue
      render json: {error: "You don't have that much money!"}, status: :unprocessable_entity
      return
    end

    PusherClient.global('bettor', {
      name: bet.user.name,
      amount: bet.amount,
      team: bet.team,
      gameId: bet.open_bet.game_id,
      betId: bet.open_bet.bet_id,
      kind: bet.open_bet.kind
    })

    current_user.bet_count += 1
    current_user.save

    render json: {message: "Bet placed!"}
  end
end
