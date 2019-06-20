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

# Download and install latest version of vault if not installed
[ -f "/usr/local/bin/vault" ] || {
  pushd /usr/local/bin
  VAULT_URL=$(curl https://releases.hashicorp.com/index.json | jq '{vault}' | egrep "linux.*amd64" | sort -r | head -1 | awk -F[\"] '{print $4}')
  curl -o vault.zip ${VAULT_URL}
  unzip vault.zip
  rm -f vault.zip
  popd
}

# Install vault autocomplete
grep 'complete -C /usr/local/bin/vault vault' /home/vagrant/.bashrc || {
  echo 'complete -C /usr/local/bin/vault vault' | tee -a /home/vagrant/.bashrc
}

grep 'exec $SHELL' /home/vagrant/.bash_profile || {
  echo 'exec $SHELL' | tee -a /home/vagrant/.bash_profile
}
