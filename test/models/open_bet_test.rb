require 'test_helper'

class OpenBetTest < ActiveSupport::TestCase
  test "should return correct bet odds" do
    open_bet = open_bets(:one)

    bet1 = bets(:one)
    bet2 = bets(:two)

    expected_odds = {:blue=>{:mult=>9.3, :pool=>15}, :purple=>{:mult=>1.1, :pool=>125}}
    assert_equal expected_odds, open_bet.odds

    user = users(:bettor_three)
    bet3 = Bet.create(open_bet: open_bet, team: 'blue', amount: 2000, user_id: user.id)

    expected_odds = {:blue=>{:mult=>1.1, :pool=>2015}, :purple=>{:mult=>17.1, :pool=>125}}
    assert_equal expected_odds, open_bet.odds
  end

  test "should have no odds if no bets" do
    open_bet = open_bets(:no_bets)

    expected_odds = {:blue=>{:mult=>0, :pool=>0}, :purple=>{:mult=>0, :pool=>0}}
    assert_equal expected_odds, open_bet.odds
  end

  test "should return integers if equivalent" do
    open_bet = open_bets(:no_bets)
    user = users(:bettor_three)
    bet = Bet.create(open_bet: open_bet, team: 'blue', amount: 10, user_id: user.id)

    expected_odds = {:blue=>{:mult=>1, :pool=>10}, :purple=>{:mult=>0, :pool=>0}}
    assert_equal expected_odds, open_bet.odds
  end
end
