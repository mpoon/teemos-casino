class TeemoBotWorker
  include Sidekiq::Worker

  def perform(open_bet_id)
    puts "Teemo's doing work!"
  end
end
