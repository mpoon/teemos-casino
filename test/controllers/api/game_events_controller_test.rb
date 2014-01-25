require 'test_helper'

class Api::GameEventsControllerTest < ActionController::TestCase
  test "should create open bet on game start" do
  	post :start, {game_id: 999}
  	assert_response :success
  	assert OpenBet.find_by(game_id: 999).state == 'open'
  end

  test "should close open bet on game end" do
  	post :start, {game_id: 999}
  	post :end, {game_id: 999, winner: 'blue'}
  	assert_response :success
  	assert OpenBet.find_by(game_id: 999).state == 'closed'
  end
end
