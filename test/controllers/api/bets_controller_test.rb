require 'test_helper'

class Api::BetsControllerTest < ActionController::TestCase
  setup :login_user

  test "should place bet" do
    post :create, {game_id: 1, team: "purple", amount: 10}
    assert_response :success
    assert_json({message: "Bet placed!"})
    assert_equal 90, User.find(users(:one)).wallet
  end

  test "should not place bet for more than wallet" do
    post :create, {game_id: 1, team: "purple", amount: 123}
    assert_response :unprocessable_entity
  end

  test "should not place bet for invalid team" do
    post :create, {game_id: 1, team: "green", amount: 10}
    assert_response :unprocessable_entity
  end

  test "should not allow multiple bets" do
    post :create, {game_id: 1, team: "purple", amount: 10}
    post :create, {game_id: 1, team: "purple", amount: 10}
    assert_response :unprocessable_entity
    assert_json({message: "Validation failed: Open bet may not have multiple bets"})
  end

  test "should not allow bet after expiration" do
    post :create, {game_id: open_bets(:expired).game_id, team: "purple", amount: 10}
    assert_response :unprocessable_entity
    assert_json({error: "Betting is not open!"})
  end

  def login_user
    login(users(:one))
  end
end
