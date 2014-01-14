class Api::BettorsController < Api::BaseController

  def show
    status = {purple: [], blue: [], top: []}
    open_bet = OpenBet.where(event: 'game').order(created_at: :desc).limit(1).first
    top = User.order(wallet: :desc).limit(10)
    active_bets = open_bet.bets

    active_bets.each do |bet|
      status[bet.team.to_sym].push({name: bet.user.name, amount: bet.amount})
    end

    top.each do |user|
      status[:top].push({name: user.name, amount: user.wallet})
    end

    render json: status
  end
end