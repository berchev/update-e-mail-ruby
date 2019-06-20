GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant';
GRANT GRANT OPTION ON *.* TO 'root'@'%';

-- Create personal_info database
CREATE DATABASE personal_info;

-- Slelect database personal_info for use
USE personal_info;

-- Create table students
CREATE TABLE students (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL, 
    CONSTRAINT PK_students PRIMARY KEY (id)
);

-- Adding records into the table
INSERT INTO students 
    ( name, email)
VALUES 
    ('georgi', 'georgi@example.bg' ),
    ('martin', 'martin@example.bg' ), 
    ('slav', 'slav@example.bg'), 
    ('chavdar', 'chavdar@example.bg'), 
    ('slav', 'slav@example.bg'), 
    ('nikolay', 'nikolay@example.bg');
