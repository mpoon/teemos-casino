# http://manuel.manuelles.nl/sidekiq-heroku-redis-calc/
# https://github.com/mperham/sidekiq/issues/117
Sidekiq.configure_client do |config|
  config.redis = { :size => 2 }
end
