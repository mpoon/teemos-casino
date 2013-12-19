class PagesController < ApplicationController

  before_filter :require_beta_access, only: :index

  def index
    #
  end

  def landing
    #
  end
end
