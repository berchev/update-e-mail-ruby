#!/usr/bin/env bash

# Debug mode enabled
set -x


# Install jq if not installed
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

# Configure MySQL to listen on all IPs, if not configured
grep "bind-address		= 0.0.0.0" /etc/mysql/mysql.conf.d/mysqld.cnf || {
  cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
  cp /vagrant/conf/mysqld.cnf /etc/mysql/mysql.conf.d/
  systemctl restart mysql.service
}

# Set username and password variables needed for MySQL access
USER=root
PASSWORD=vagrant

# We create our database in this way
# TODO: Review flyway for database migration!!!!
# Check if personal_info database exist, if not configure it
mysql -u${USER} -p${PASSWORD} -e "show databases;" | grep "personal_info" || {
  mysql -u${USER} -p${PASSWORD} -e "source /vagrant/scripts/setup_mysql.sql"
}
