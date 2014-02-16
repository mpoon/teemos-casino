class Api::BettorsController < Api::BaseController

  def show
    bettors = {top: [], bets: []}

    open_bets = OpenBet.where(state: 'open')

    open_bets.each do |open_bet|
      active_bets = open_bet.bets || []
      bettors[:bets] = {kind: open_bet.kind, purple: [], blue: []}

      active_bets.each do |bet|
        bettors[:bets][bet.team.to_sym].push({
          name: bet.user.name,
          amount: bet.amount
        })
      end
    end

    topWealthy = User.order(wallet: :desc).limit(10)

    topWealthy.each do |user|
      bettors[:top].push({
        name: user.name,
        amount: user.wallet
      })
    end

    render json: bettors
  end
end
