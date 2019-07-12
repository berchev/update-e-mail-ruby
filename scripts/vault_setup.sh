#!/usr/bin/env bash
export VAULT_ADDR='http://0.0.0.0:8200'

################### MySQL ###################
# Variables
mysql_ip_port="192.168.56.11:3306"
database_name="personal_info"
plugin_name="mysql-database-plugin" 
username="root" 
password="vagrant"
allowed_roles="mysqlrole" 

# enable the database capabilities of vault
vault secrets enable database

# telling the database engine which plugin to use, and the connection information.
vault write database/config/${database_name} \
 plugin_name=${plugin_name} \
 connection_url="{{username}}:{{password}}@tcp(${mysql_ip_port})/" \
 allowed_roles=${allowed_roles} \
 username=${username} \
 password=${password}

# Create new vault role to match database configuration
vault write database/roles/mysqlrole \
    db_name=${database_name} \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL PRIVILEGES ON ${database_name}.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

# Write policy for application server.  
vault policy write mysql mysql.hcl

# Create token for application server in order to read mysql secrets
vault token create -policy=mysql | grep 'token ' | awk '{print $2}' > mysql_token.txt

################## Slack ######################
# Slack webhook_url need to be provided as an argument during script execution
link=$1

# Enable new kv secret engine "slack" version 1
vault secrets enable -path="slack" -version=1 kv

# Create secret url which match slack webhook url
vault kv put slack/webhook_url url=${link}

# Add new policy relatad to our application
vault policy write slack slack.hcl

# Create token based on slack policy
vault token create -policy=slack |  grep 'token ' | awk '{print $2}' > slack_token.txt
