require 'test_helper'

class BetPayoutWorkerTest < ActiveSupport::TestCase
  setup :create_worker

  test "pays out correctly to loser" do
    open_bet = open_bets(:one)
    bet = bets(:one)
    user = bet.user

    initial = user.wallet
    expected = initial

    @worker.perform(open_bet.id)
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "pays out correctly to winner" do
    open_bet = open_bets(:one)
    bet = bets(:two)
    user = bet.user

    initial = user.wallet
    expected = initial + (bet.amount * event.bet_odds[bet.team.to_sym])

    @worker.perform(open_bet.id)
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "bet is destroyed" do
    refute_empty open_bets(:one).bets
    @worker.perform(open_bets(:one).id)
    assert_empty open_bets(:one).bets
  end

  def create_worker
    @worker = BetPayoutWorker.new
  end
end
