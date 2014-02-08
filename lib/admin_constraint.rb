class AdminConstraint
  def matches?(request)
    return true if Rails.env == 'development'

    return false unless request.session[:_current_user_id]
    User.find(request.session[:_current_user_id]).admin?
  end
end
