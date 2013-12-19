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
    expected = initial + (bet.amount * open_bet.odds[bet.team.to_sym][:mult]).to_i

    @worker.perform(open_bet.id)
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "pays out welfare if loser goes bust" do
    bet = bets(:loser)
    open_bet = bet.open_bet
    user = bet.user

    user.update!(wallet: 1)

    expected = user.wallet_minimum

    @worker.perform(open_bet.id)
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "bet is destroyed" do
    refute_empty open_bets(:one).bets
    @worker.perform(open_bets(:one).id)
    assert_empty open_bets(:one).bets
  end

  test "open_bet is resolved" do
    assert_equal "open", open_bets(:one).state
    @worker.perform(open_bets(:one).id)
    assert_equal "resolved", open_bets(:one).reload.state
  end

  test "updates bet streak" do
    bet = bets(:winner)
    user = bet.user
    assert_equal 0, user.bet_streak
    @worker.perform(bet.open_bet.id)
    assert_equal 1, user.reload.bet_streak
  end

  def create_worker
    @worker = BetPayoutWorker.new
  end
end
