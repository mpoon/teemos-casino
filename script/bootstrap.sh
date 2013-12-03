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

## ruby/rails deps
apt-get install -y libsqlite3-dev nodejs

## set up db
sudo -u postgres psql -c "DROP DATABASE IF EXISTS vagrant;"
sudo -u postgres psql -c "DROP ROLE IF EXISTS vagrant;"
sudo -u postgres psql -c "CREATE USER vagrant WITH PASSWORD 'vagrant';"
sudo -u postgres psql -c "create database vagrant;"

## Set up ruby
sudo gem install bundler

echo "Success!"
