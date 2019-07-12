# update-e-mail-ruby
This repo represents dev environment with 3 VMs:
- **mysql-client01** - representing our update-email ruby application (app.rb)
- **mysql01**  - representing our MySQL Database (where students names and emails are stored)
- **vault01** - representing our Vault server (which generates database user and password, used from app.rb)

## Requirements
- [Virtualbox installed](https://www.virtualbox.org/)
- [Vagrant installed](https://www.vagrantup.com/intro/getting-started/install.html)

## Repo content
| File                   | Description                      |
|         ---            |                ---               |
| conf/mysqld.cnf | mysql configuration |
| scripts/mysql01_provision.sh | provision script for mysql01 VM |
| scripts/vault01_provision.sh | provision script for vault01 VM |
| scripts/setup_mysql.sql | sql script required to setup mysql01 VM |
| scripts/vault_setup.sh | script required to setup vault01 VM |
| Vagrantfile | Vagrant configuration file |
| app.rb | ruby application which update email of specific student |
| mysql.hcl | policy file. Vault token with specific permissions, will be created based on that policy file |
| slack.hcl | policy file. Vault token with specific permissions, will be created based on that policy file |


## Description
**mysql-client01**(app.rb) is application that updates email of specific student from **mysql01**. The ruby application(app.rb) connect to the MySQL database using token provided form **vault01** VM

## Setup dev environment
- `git clone https://github.com/berchev/update-e-mail-ruby.git` - download the project
- `cd update-e-mail-ruby` - change to project directory 
- `vagrant up` - create dev Vagrant environment
- `vagrant status` - will status of all 3 VMs
- `vagrant ssh <VM name>` - establish ssh connection to desired VM (example: vagrant ssh mysql-client01)

## Vault setup
- `vagrant ssh vault01` - connect to vault01 machine
- `cd /vagrant` - change to /vagrant directory
- `export VAULT_DEV_ROOT_TOKEN_ID=changeme` - set ENV variable **changeme**, which is going to be default root token when Vault server is started
- `vault server -dev -dev-listen-address 0.0.0.0:8200` - start Vault server in dev mode, listening on all IP addresses
- connect to vault server from another terminal
- `cd /vagrant` - change to /vagrant directory
- `bash scripts/vault_setup.sh your_slack_webhook_url` - script is going to configure your vault server(enable and configure database capability, enable slack KV engine, create token for app01 to read mysql secrets, create token for app01 in order to read slack webhook url)

## Update given e-mail
- open another terminal for our app01 machine
- `vagrant ssh mysql-client01` - in order to connect to app01
- `cd /vagrant` - change to /vagrant director
- `ruby app.rb` - in order to run the update email application
- Follow the instructions

## DONE
- [x] use MySQL database
- [x] write application which purpose is to update student e-mail
- [x] use Vault in order to authenticate Application against MySQL database
- [x] use Dynamic secrets
- [x] find more ruby way to parse current_table
- [x] refactor next two blocks to avoid duplicate code (format_as_table function has been written)
- [x] If student name == exit we exit
- [x] Print current vault user as infomation for the operator
- [x] make application to exit smoothly with `ctrl + c`
- [x] include sclack notification when e-mail has been updated and print vault user into slack channel
- [x] create KV secret engine for slack webhook URL

## TODO
- [ ] Review flyway for database migration
