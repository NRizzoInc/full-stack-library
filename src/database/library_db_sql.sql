-- Project Code 
-- Last Updated: 2021/11/07


CREATE DATABASE IF NOT EXISTS libSystem;
USE libSystem;


-- The library system (such as all libraries in 1 city)
CREATE TABLE library_system
 (
    library_sys_id INT PRIMARY KEY NOT NULL,
    library_sys_name VARCHAR(100)
 );


-- drop table employee;
-- Represents someone who works at a library in the library system
CREATE TABLE employee
 (
    employee_id INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE,
    salary INT,
    job_role VARCHAR(50)  
   -- CONSTRAINT 
 );