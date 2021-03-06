# Teemo's Casino

Salts' Ahoy!

## Quick Install
  The quickest way to get started is to clone the project and utilize it like this:

  Install [Vagrant](http://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 
  Start up Vagrant

    vagrant up

  SSH in

    vagrant ssh

  Install dependencies and prepare the database:

    cd /vagrant
    bin/bundle install
    bin/rake db:setup

  Start the workers (optional)

    bin/bundle exec sidekiq

  And finally the server

    bin/rails server

  Then open a browser and go to:

    http://localhost:3000

## Development

  Rails Console. So interactive!

    bin/rails console

  Workers (debug page at `/debug/sidekiq` for admins)

    bin/bundle exec sidekiq

### Testing

  Running all tests

    bin/rake test

  Running all tests without recreating database (somewhat faster)

    bin/rake test:all

  Running a specific test

    bin/rake test TEST=test/workers/bet_payout_worker_test.rb

### Deploying

Push to heroku!

    git push heroku master

Spin up worker dynos

  heroku ps:scale worker=1

Spin down worker dynos

  heroku ps:scale worker=0

Turn on closed beta

  heroku config:add CLOSED_BETA=true

### Migrations

Create the migration

    bin/rails generate model GameEvents

And run it on dev

    bin/rake db:migrate

then production (`brew install heroku`)

    heroku run rake db:migrate

See the [migrations guide](http://guides.rubyonrails.org/migrations.html) for more

## Troubleshooting

#### CDN Requirement

  To visit the site without going through the CDN, first hit `/bypass`

### Vagrant

#### Vagrant Cachier

  Install `vagrant-cachier` to make vagrant provisioning faster

    vagrant plugin install vagrant-cachier

#### Re-Provisioning

  If `vagrant up` didn't provision for whatever reason

    vagrant provision

#### Time

  Sometimes the clock gets out of sync

    sudo ntpdate -s time.nist.gov
