# Sentry/raven sidekiq integration
require 'raven/sidekiq'

# http://manuel.manuelles.nl/sidekiq-heroku-redis-calc/
# https://github.com/mperham/sidekiq/issues/117

Sidekiq.configure_client do |config|
  config.redis = { :size => 2 }
end

Sidekiq.configure_server do |config|
  config.poll_interval = 0.5
end
