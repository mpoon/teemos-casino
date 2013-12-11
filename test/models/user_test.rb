require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "#update_bet_streak updates correctly" do
    u = users(:one)

    u.bet_streak = 0
    u.update_bet_streak :win
    assert_equal 1, u.bet_streak
    u.update_bet_streak :win
    assert_equal 2, u.bet_streak
    u.update_bet_streak :loss
    assert_equal -1, u.bet_streak

    u.bet_streak = -5
    u.update_bet_streak :win
    assert_equal 1, u.bet_streak
    u.update_bet_streak :loss
    assert_equal -1, u.bet_streak
    u.update_bet_streak :loss
    assert_equal -2, u.bet_streak
  end
end
