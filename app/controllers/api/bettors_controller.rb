class Api::BettorsController < Api::BaseController

  def show
    bettors = {top: [], bets: []}

    open_bets = OpenBet.where(state: 'open')

    open_bets.each do |open_bet|
      active_bets = open_bet.bets || []
      open_bet_bettors = {kind: open_bet.kind, purple: [], blue: []}

      active_bets.each do |bet|
        open_bet_bettors[bet.team.to_sym].push({
          name: bet.user.name,
          amount: bet.amount
        })
      end

      bettors[:bets].push(open_bet_bettors)
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
