class SessionsController < ApplicationController
  before_filter :beta_whitelist, :only => [:create]

  def create
    puts auth_hash
    user = User.find_or_initialize_by(twitch_id: auth_hash.uid.to_s)

    if user.new_record?
      user.wallet = 100
    end

    user.assign_attributes({
      name: auth_hash.info.nickname,
      email:  auth_hash.info.email,
    })

    if user.save
      session[:_current_user_id] = user.id
      redirect_to :root
    else
      raise Exception.new(user.errors)
    end
  end

  def destroy
    session[:_current_user_id] = nil
    redirect_to :root
  end

  protected

  def beta_whitelist
    if (TeemosCasino::Application.config.beta &&
      !TeemosCasino::Application.config.beta_whitelist.include?(auth_hash.info.nickname))
      redirect_to :root
    end
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
