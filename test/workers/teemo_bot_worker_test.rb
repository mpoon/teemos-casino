require 'test_helper'

class TeemoBotWorkerTest < ActiveSupport::TestCase
  setup :create_worker

  test "#bet_amount creates values in range" do
    amount = @worker.bet_amount(10)
    assert_includes 5..15, amount

    amount = @worker.bet_amount(0)
    assert_includes 1..1, amount

    amount = @worker.bet_amount(100)
    assert_includes 50..100, amount

    amount = @worker.bet_amount(1000)
    assert_includes 50..100, amount
  end

  def create_worker
    @worker = TeemoBotWorker.new
  end
end
