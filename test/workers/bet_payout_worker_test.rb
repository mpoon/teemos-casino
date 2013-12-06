require 'test_helper'

class BetPayoutWorkerTest < ActiveSupport::TestCase
  setup :create_worker

  test "pays out correctly to loser" do
    event = game_events(:one_end)
    bet = bets(:one)
    user = bet.user

    initial = user.wallet
    expected = initial

    @worker.perform(game_events(:one_end))
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "pays out correctly to winner" do
    event = game_events(:one_end)
    bet = bets(:two)
    user = bet.user

    initial = user.wallet
    expected = initial + (bet.amount * event.bet_odds[bet.team.to_sym])

    @worker.perform(game_events(:one_end))
    wallet = User.find(user).wallet

    assert_equal expected, wallet
  end

  test "bet is destroyed" do
    refute_empty Bet.where(game_id: game_events(:one_end).game_id)
    @worker.perform(game_events(:one_end))
    assert_empty Bet.where(game_id: game_events(:one_end).game_id)
  end

  def create_worker
    @worker = BetPayoutWorker.new
  end
end
