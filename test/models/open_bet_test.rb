require 'test_helper'

class OpenBetTest < ActiveSupport::TestCase
  test "should return correct bet odds" do
    open_bet = open_bets(:one)

    bet1 = bets(:one)
    bet2 = bets(:two)

    expected_odds = {blue: 9.33, purple: 1.12}
    assert_equal expected_odds, open_bet.odds

    user = users(:bettor_three)
    bet3 = Bet.create(open_bet: open_bet, team: 'blue', amount: 2000, user_id: user.id)

    expected_odds = {blue: 1.06, purple: 17.12}
    assert_equal expected_odds, open_bet.odds
  end
end
