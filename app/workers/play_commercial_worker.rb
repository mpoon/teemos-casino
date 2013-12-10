class PlayCommercialWorker
  include Sidekiq::Worker

  def perform
    unless Rails.configuration.commercials.enabled
      logger.info("Commercials not enabled; not triggering") and return
    end

    channel = Rails.configuration.commercials.channel
    access_token = Rails.configuration.commercials.access_token
    uri = URI("https://api.twitch.tv/kraken/channels/#{channel}/commercial")

    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Post.new uri
      request['Authorization'] = "OAuth #{access_token}"
      request['Accept'] = 'application/vnd.twitchtv.v3+json'
      request.set_form_data('length' => '90')
      response = http.request request
    end
  end
end
