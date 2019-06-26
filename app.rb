#!/usr/bin/env ruby

# Loading mysql library
require 'mysql2'

# Loading vault library
require 'vault' 

# Format_as_table function definition
def format_as_table(input)
  input.each do |row|
    hash = row
    array = hash.values
    puts array.join(' - ')
  end
end

# Get mysql token value from mysql_token.txt file and remove the last new line character
mysql_token = File.open("mysql_token.txt", "r") { |file| file.read }.delete!("\n")

# Estabish connection to vault
Vault.configure do |config| 
  config.address = "http://192.168.56.31:8200"
  config.token = mysql_token
end

# Get new login credentials for mysql database
secret = Vault.logical.read("database/creds/mysqlrole")

# Mysql variables definition
database = "personal_info"
host = "192.168.56.11"
username = secret.data[:username]
password = secret.data[:password]


# Establish connection to MySQL database
client = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)

# Print your username
puts
puts "Your currently generated username from Vault is: #{username}"

# Get all current results from students table
results = client.query("SELECT id,name,email FROM students")

puts
puts "List of current emails:"
puts "-----------------------"

# Format as table the row data from MySQL database (show current students table)
format_as_table(results)

# Add all student names and emails from MySQL to separate arrays
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
puts
puts

# Ask Operator to choose student name and e-mail
while true
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
        puts "this is not e-mail address at all"
        puts "Try again!"
      else
        # Connect to MySQL and update the email address of specific user
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
