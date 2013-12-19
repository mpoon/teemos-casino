class PagesController < ApplicationController
  def index
    if TeemosCasino::Application.config.beta && current_user.nil?
      render :beta_landing
    else
      expires_in 10.minutes, public: true
    end
  end
end
