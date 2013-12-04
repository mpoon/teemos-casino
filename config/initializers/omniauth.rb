
TWITCH_CONFIG = YAML.load_file(Rails.root.join("config/twitch.yml"))[::Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitchtv, TWITCH_CONFIG['client_id'], TWITCH_CONFIG['client_secret'], {
    # this gem is retarded
    scope: 'user_read channel_read',
    scopes: 'user_read channel_read'
  }
end

OmniAuth.config.logger = Rails.logger
