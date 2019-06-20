#!/usr/bin/env bash

# Debug mode enabled
set -x

# install jq if not installed
which jq || {
  apt-get update
  apt-get install -y jq
} 

# Download and install latest version of vault if not installed
[ -f "/usr/local/bin/vault" ] || {
  pushd /usr/local/bin
  VAULT_URL=$(curl https://releases.hashicorp.com/index.json | jq '{vault}' | egrep "linux.*amd64" | sort -r | head -1 | awk -F[\"] '{print $4}')
  curl -o vault.zip ${VAULT_URL}
  unzip vault.zip
  rm -f vault.zip
  popd
}

# install vault autocomplete
grep 'complete -C /usr/local/bin/vault vault' /home/vagrant/.bashrc || { 
  echo 'complete -C /usr/local/bin/vault vault' | tee -a /home/vagrant/.bashrc
}

grep 'exec $SHELL' /home/vagrant/.bash_profile || {
  echo 'exec $SHELL' | tee -a /home/vagrant/.bash_profile
}
