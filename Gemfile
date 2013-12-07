source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'slim'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Angular template compilation
gem 'ejs'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'pusher'
gem 'omniauth'
gem 'omniauth-twitchtv' , github: 'masterkain/omniauth-twitchtv'
gem 'sentry-raven'
gem 'newrelic_rpm'

gem 'sinatra', '>= 1.3.0', :require => nil # Sidekiq web UI
gem 'sidekiq'

# Set ENV variables from .env
gem 'dotenv-rails', groups: [:development, :test]

# Use debugger
gem 'debugger', group: [:development, :test]

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

ruby "2.0.0"
