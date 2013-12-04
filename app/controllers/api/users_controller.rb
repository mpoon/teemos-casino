class Api::UsersController < ApplicationController
  def show
    if not current_user
      render json: {error: "Unauthorized"}, status: 401
    else
      # TODO: don't render entire user object
      render json: current_user
    end
  end
end
