#!/usr/bin/env bash
export VAULT_ADDR='http://0.0.0.0:8200'

# Variables
mysql_ip_port="192.168.56.11:3306"
database_name="personal_info"
plugin_name="mysql-database-plugin" 
username="root" 
password="vagrant"
allowed_roles="mysqlrole" 

# enable the database capabilities of vault
vault secrets enable database

# we need to tell the database engine which plugin to use, and the connection information.
vault write database/config/${database_name} \
 plugin_name=${plugin_name} \
 connection_url="{{username}}:{{password}}@tcp(${mysql_ip_port})/" \
 allowed_roles=${allowed_roles} \
 username=${username} \
 password=${password}

	
vault write database/roles/mysqlrole \
    db_name=${database_name} \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON ${database_name}.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

vault read database/creds/mysqlrole | egrep 'password|username' | awk '{print $2}' | tee >(grep "v-token" > username.txt) | grep -v "v-token" > password.txt
