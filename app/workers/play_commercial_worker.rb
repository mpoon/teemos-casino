class PlayCommercialWorker
  include Sidekiq::Worker

  def perform()
    uri = URI('https://api.twitch.tv/kraken/channels/teemoscasino/commercial')
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new uri
      request['Authorization'] = "OAuth #{COMMERCIAL_CONFIG['access_token']}"
      request['Accept'] = 'application/vnd.twitchtv.v3+json'
      request.set_form_data('length' => '90')
      response = http.request request
    end
  end
end