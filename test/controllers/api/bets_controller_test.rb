require 'test_helper'

class Api::BetsControllerTest < ActionController::TestCase
  setup :login_user

  test "should place bet" do
    current_user = User.find(users(:one))
    prev_bet_count = current_user.bet_count
    post :create, {game_id: 1, bet_id: 1, kind: 'game', team: "purple", amount: 10}
    assert_response :success
    assert_json({message: "Bet placed!"})
    assert_equal 90, current_user.wallet
    assert_equal prev_bet_count + 1, current_user.bet_count
  end

  test "should not place bet for more than wallet" do
    post :create, {game_id: 1, bet_id: 1, kind: 'game', team: "purple", amount: 123}
    assert_response :unprocessable_entity
    assert_json({error: "You don't have that much money!"})
  end

  test "should not place bet for invalid team" do
    post :create, {game_id: 1, bet_id: 1, kind: 'game', team: "green", amount: 10}
    assert_response :unprocessable_entity
    assert_json({message: "green is not a valid team"})
  end

  test "should not allow multiple bets" do
    post :create, {game_id: 1, bet_id: 1, kind: 'game', team: "purple", amount: 10}
    post :create, {game_id: 1, bet_id: 1, kind: 'game', team: "purple", amount: 10}
    assert_response :unprocessable_entity
    assert_json({message: "Validation failed: Open bet may not have multiple bets"})
  end

  test "should not allow bet after expiration" do
    post :create, {game_id: open_bets(:expired).game_id, , bet_id: 1, kind: 'game', team: "purple", amount: 10}
    assert_response :unprocessable_entity
    assert_json({error: "Betting is not open!"})
  end

  test "should respond with empty status when no open_bets" do
  end

  test "should respond with placed status when there are active bets" do
  end

  test "should respond with open status when open bet is not expired" do
  end

  test "should respond with closed status when open bet is expired" do
  end

  def login_user
    login(users(:one))
  end
end
