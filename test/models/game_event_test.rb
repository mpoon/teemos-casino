require 'test_helper'

class GameEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should return correct bet odds" do
    event = game_events(:one_start)

    bet1 = bets(:one)
    bet2 = bets(:two)

    expected_odds = {blue: 9.33, purple: 1.12}
    assert_equal expected_odds, event.bet_odds

    user = users(:bettor_three)
    bet3 = Bet.create(game_id: event.game_id, team: 'blue', amount: 2000, user_id: user.id)

    expected_odds = {blue: 1.06, purple: 17.12}
    assert_equal expected_odds, event.bet_odds
  end
end
