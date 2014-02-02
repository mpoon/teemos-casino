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

  test "should create open bet on sidebet start" do
    post :open_sidebet {game_id: 999, kind: 'player_death'}
    assert_response :success
    assert OpenBet.find_by(game_id: 999, kind: 'player_death').state == 'open'
  end

  test "should close open bet on sidebet end" do
    post :open_sidebet {game_id: 999, kind: 'player_death'}
    post :close_sidebet {game_id: 999, kind: 'player_death', winner: 'blue'}
    assert_response :success
    assert OpenBet.find_by(game_id: 999, kind: 'player_death').state == 'closed'
  end
end
