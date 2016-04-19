# Sentry/raven sidekiq integration
require 'raven/sidekiq'

# http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/
# https://github.com/mperham/sidekiq/issues/117

Sidekiq.configure_client do |config|
  config.redis = { :size => 2 }
end

Sidekiq.configure_server do |config|
  config.poll_interval = 5
end
