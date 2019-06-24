#!/usr/bin/env bash

# Debug mode enabled
set -x

# install jq if not installed
which jq || {
  apt-get update
  apt-get install -y jq
} 

# Install mysql client if not installed
dpkg -l libmysqlclient-dev || {
  apt-get update
  apt-get install -y libmysqlclient-dev
}

# Install gem mysql2 if not installed
gem list -i mysql2 || gem install mysql2

# If gem vault is not installed, install it
gem list -i vault || gem install vault
