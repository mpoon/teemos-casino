#!/usr/bin/env bash
set -e

apt-get update
apt-get install -y software-properties-common python-software-properties
add-apt-repository ppa:brightbox/ruby-ng-experimental
apt-get update

apt-get install -y git

# build dependencies
apt-get install -y libpq-dev make g++

apt-get install -y ruby2.0 ruby2.0-dev ruby2.0-doc

apt-get install -y redis-server postgresql libsqlite3-dev
apt-get install postgresql-contrib # hstore

## ruby/rails deps
apt-get install -y libsqlite3-dev nodejs

## set up db
### For rails tests - https://gist.github.com/gstark/2554213#comment-828371
pg_dropcluster --stop 9.1 main
pg_createcluster --start --locale en_US.UTF-8 9.1 main
sudo -u postgres psql -c "DROP DATABASE IF EXISTS vagrant;"
sudo -u postgres psql -c "DROP ROLE IF EXISTS vagrant;"
sudo -u postgres psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant' SUPERUSER;"
sudo -u postgres psql -c "create database vagrant;"

## Set up ruby
sudo gem install bundler

echo "Success!"
