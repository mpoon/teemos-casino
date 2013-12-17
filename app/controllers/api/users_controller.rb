class Api::UsersController < Api::BaseController
  before_filter :require_auth

  def show
    render json: {
      id: current_user.id,
      name: current_user.name,
      wallet: current_user.wallet,
      stats: current_user.stats
    }
  end
end
