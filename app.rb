#!/usr/bin/env ruby

# Loading redis library
require 'mysql2'

# Variables definition
username = File.open("username.txt", "r") { |file| file.read }.delete!("\n")
password = File.open("password.txt", "r") { |file| file.read }.delete!("\n")
database = "personal_info"
host = "192.168.56.11"

# Establish connection to MySQL database
client = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)

# Get all current results from students table
current_table = client.query("SELECT id,name,email FROM students")

# Show current table values for convenience
puts "List of current emails:"
puts "-----------------------"
current_table.each do |hash_row|
  array = hash_row.values_at("id", "name", "email")
  puts array.join(' - ')
end

# TODO: find more ruby way to parse current_table
# Add all student names and emails from MySQL to separate arrays
all_names = []
all_emails = []
current_table.each do |hash_row|
  hash_row.each do |key, value|
    if key == "name"
      all_names << value
    elsif key == "email"
      all_emails << value
    end
  end
end

# Ask Operator to choose student name
puts
puts
puts "Please select student name: "
student_name = gets.chomp

# Check if student name exists into database
# Ask Operator to enter e-mail and verify if the e-mail is real one or is not duplicated 
if all_names.include?(student_name)
  puts "Please enter a new email for #{student_name}: "
  new_email = gets.chomp
  unless !all_emails.include?(new_email) && new_email.include?('@example.bg')
    puts "ERROR !"
    puts "E-mail already exists or this is not e-mail address at all !!"
    puts "Try again!"
    exit
  end  
else
  puts "You have entered NOT existing name!"
  puts "Try again!"
  exit
end

# Connect to MySQL and update the email address of specific user
update_email = client.query("UPDATE students SET email = \"#{new_email}\" WHERE name = \"#{student_name}\"")

# TODO: refactor next two blocks to avoid duplicate code
# Get results from updated students table
new_table = client.query("SELECT id,name,email FROM students")

# Show new table values for convenience
puts
puts
puts "List of current emails:"
puts "-----------------------"
new_table.each do |hash_row|
  array = hash_row.values_at("id", "name", "email")
  puts array.join(' - ')
end
