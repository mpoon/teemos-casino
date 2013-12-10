class Api::BaseController < ApplicationController

  rescue_from 'ActiveRecord::RecordInvalid', :with => :render_422

  def render_422(e)
    logger.error("Record Error: #{e}")
    render json: {message: e.message}, status: :unprocessable_entity
  end
end
