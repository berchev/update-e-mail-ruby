#!/usr/bin/env ruby

# Loading mysql library
require 'mysql2'

# Loading vault library
require 'vault' 

# Loading slack library
require 'slack-notifier'

####################################### FUNCTION DEFINITION START #######################################################
# Format_as_table function definition
def format_as_table(input)
  input.each do |row|
    hash = row
    array = hash.values
    puts array.join(' - ')
  end
end

# Connection to vault function definition
def vault_connection(vault_adress, token)
  Vault.configure do |config|
    config.address = vault_adress
    config.token = token
  end
end

# Read token value function
def read_token(target_file)
  File.open(target_file, "r") do |file| 
    file.read.delete!("\n")
  end
end
#################################### FUNCTION DEFINITION END  #########################

######################################  RUBY PROGRAM START  ###########################

######################################  SLACK MAIN CONFIGURATION START #####################
# Get slack token value from slack_token.txt file and remove the last new line character
slack_token = read_token("slack_token.txt")

# Add vault slack secret engine path as variable for convenience
slack_secret_path = "slack/webhook_url"

# Estabish connection to vault using slack token
vault_connection("http://192.168.56.31:8200", slack_token)

# Get the slack key/value pair from vault
slack_secret = Vault.logical.read(slack_secret_path)

# Extract the webhook url value from "slack/webhook_url" kv store
webhook_url = slack_secret.data[:url]

# Slack channel and username configuration
notifier = Slack::Notifier.new webhook_url do
  defaults channel: "#feed-georgi",
           username: "app.rb"
end

###################################  SLACK MAIN CONFIGURATION END #########################

###################################  MYSQL MAIN CONFIGURATION START #########################
# Get mysql token value from mysql_token.txt file and remove the last new line character
mysql_token = read_token("mysql_token.txt")

# Add vault mysql role path as variable for convenience
mysql_role_path = "database/creds/mysqlrole"

# Estabish connection to vault using myqsl token
vault_connection("http://192.168.56.31:8200", mysql_token)

# Get new login credentials for mysql database
secret = Vault.logical.read(mysql_role_path)

# Mysql variables definition
database = "personal_info"
host = "192.168.56.11"
username = secret.data[:username]
password = secret.data[:password]

###################################  MYSQL MAIN CONFIGURATION END #########################

# Establish connection to MySQL database
client = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)

# Print your username
puts
puts "Your currently generated username from Vault is: #{username}"

# Slack message body - vault user
slack_vault_user = {
                     title: "vault new user generated",
                     text: "username: *#{username}*",
                     color: "good"
}

# Sending informational event at slack about vault user
notifier.post attachments: [slack_vault_user]

# Get all current results from students table
results = client.query("SELECT id,name,email FROM students")

puts
puts "List of current emails:"
puts "-----------------------"

# Format as table the row data from MySQL database (show current students table)
format_as_table(results)
puts
puts

# Ask Operator to choose student name and e-mail
begin
  while true
    results = client.query("SELECT id,name,email FROM students")
    all_names = []
    all_emails = []
    results.each do |hash|
      hash.each do |key, value|
        if key == "name"
          all_names.push(value)
        elsif key == "email"
          all_emails.push(value)
        end
      end
    end
    combined = Hash[all_names.zip(all_emails)]
    puts "Please select student name or type 'exit' to quit: "
    student_name = gets.chomp
    if student_name == "exit"
      puts "Bye Bye!"
      break
    elsif all_names.include?(student_name)
      while true
        puts
        puts "Please enter a new email for #{student_name} or type 'exit' to quit: "
        new_email = gets.chomp
        if new_email == "exit"
          break
        elsif all_emails.include?(new_email)
          puts
          puts "ERROR !"
          puts "E-mail already exists !!"
          puts "Try again!" 
        elsif !new_email.include?('@example.bg')
          puts
          puts "ERROR !"
          puts "This is not a valid e-mail address!"
          puts "Try again!"
        else
          # Connect to MySQL and update the email address of specific user (including slack notification)
          slack_email = {
                  title: "new email assigned",
                  text: "You have updated *#{student_name}* e-mail from *#{combined[student_name]}* to *#{new_email}*",
                  color: "warning"
          }
          notifier.post attachments: [slack_email]
          update_email = client.query("UPDATE students SET email = \"#{new_email}\" WHERE name = \"#{student_name}\"")

          # Get results from updated students table
          updated_results = client.query("SELECT id,name,email FROM students")
          puts
          puts
          puts "List of updated emails:"
          puts "-----------------------"

          # Format as table the row data from updated MySQL database (shows updated students table)
          format_as_table(updated_results) 
        end
      end
    else
      puts "You have entered NOT existing name!"
      puts "Try again!"
    end
  end
rescue Interrupt => e
  puts " -> You have used 'control-C' to quit!"
  puts "Bye Bye! " 
end