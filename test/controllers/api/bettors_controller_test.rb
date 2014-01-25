require 'test_helper'

class Api::BettorsControllerTest < ActionController::TestCase
  test "should return current bettors sorted wallet desc" do
    open_bet = OpenBet.create!(game_id: 999, event: "game",
      state: :open, expires_at: 9999999999)
    Bet.create!(open_bet: open_bet, team: 'blue', user: users(:one),
      amount: 1)
    Bet.create!(open_bet: open_bet, team: 'purple', user: users(:bettor_one),
      amount: 100)
    Bet.create!(open_bet: open_bet, team: 'purple', user: users(:bettor_three),
      amount: 999)
    get :show
    assert_response :success
    assert_json({purple: [{'name'=>'testbettor3', 'amount'=>999},
        {'name'=>'testbettor1', 'amount'=>100}],
      blue: [{'name'=>'testuser1', 'amount'=>1}],
      top: [{'name'=>'testbettor3', 'amount'=>999999},
        {'name'=>'testbettor1', 'amount'=>500},
        {'name'=>'testuser1', 'amount'=>100},
        {'name'=>'testbettor2', 'amount'=>10},
        {'name'=>'testbettor4', 'amount'=>1}]})
  end
end
