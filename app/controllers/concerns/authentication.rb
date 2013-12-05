module Authentication
  extend ActiveSupport::Concern

  def current_user
    return nil unless session[:_current_user_id]
    @_current_user ||= User.find(session[:_current_user_id])
  end

  def require_auth
    if not current_user
      render json: {error: "Unauthorized"}, status: 401
    end
  end
end
