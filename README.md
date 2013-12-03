# Teemo's Casino

[...]

## Quick Install
  The quickest way to get started is to clone the project and utilize it like this:

  Install [Vagrant](http://downloads.vagrantup.com) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

  Start up Vagrant

    vagrant up

  SSH in

    vagrant ssh

  Install dependencies:

    cd /vagrant
    bundle install

  Start the server

    bin/rails server

  Then open a browser and go to:

    http://localhost:3000

## Deploying

Push to heroku!

    git push heroku master

## Debugging

    TODO

## Migrations

Create the migration

    TODO

And run it on dev

    TODO

then production

    TODO

See the [migrations guide](http://guides.rubyonrails.org/migrations.html) for more

## Troubleshooting

#### CDN Requirement

  To visit the site without going through the CDN, first hit `/bypass`

### Vagrant

  If you get NFS issues, try running the following

    sudo nfsd checkexports
    vagrant reload

#### Re-Provisioning Vagrant

  If `vagrant up` didn't provision for whatever reason

    vagrant provision

