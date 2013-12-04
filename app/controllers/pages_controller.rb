class PagesController < ApplicationController
  def index
    expires_in 10.minutes, public: true
  end
end
