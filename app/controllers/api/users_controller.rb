class Api::UsersController < Api::BaseController
  before_filter :require_auth

  def show
    # TODO: don't render entire user object
    render json: current_user
  end
end
