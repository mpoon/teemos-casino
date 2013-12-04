module Authentication
  extend ActiveSupport::Concern

  def current_user
    return nil unless session[:_current_user_id]
    @current_user ||= User.find(session[:_current_user_id])
  end
end
