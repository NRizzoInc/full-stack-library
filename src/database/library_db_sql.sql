-- Project Code 
-- Last Updated: 2021/11/10

-- DROP DATABASE libsystem;

CREATE DATABASE IF NOT EXISTS libSystem;
USE libSystem;

DROP TABLE IF EXISTS library_system;
-- The library system (such as all libraries in 1 city)
CREATE TABLE library_system
 (
    library_sys_id INT PRIMARY KEY NOT NULL,
    library_sys_name VARCHAR(100)
 );

DROP TABLE IF EXISTS library;
 -- Represents a library branch in the system
 CREATE TABLE library
 (
  library_id INT PRIMARY KEY NOT NULL,
  library_system INT NOT NULL,
  library_name VARCHAR(100) NOT NULL,
  address VARCHAR(100),
  hours_of_operation int,
  -- how many books can an individual check out of THIS branch at one time
  -- The default is 1 book per user
  max_concurrently_borrowed INT NOT NULL DEFAULT 1,
  
  -- What library system does this branch belong to
  CONSTRAINT FK_lib_system
        FOREIGN KEY (library_system) REFERENCES library_system(library_sys_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
 );
 
 DROP TABLE IF EXISTS lib_user;
-- A user in the library system
CREATE TABLE lib_user
(
 user_id INT PRIMARY KEY NOT NULL,
 first_name VARCHAR(50) NOT NULL,
 last_name VARCHAR(50) NOT NULL,
 dob DATE NOT NULL,
 -- number of books the user has checked out
 num_borrowed INT,
 -- is this user an account of an employee?
 is_employee boolean DEFAULT FALSE,
 
 -- username used to login
 username VARCHAR(50) NOT NULL,
 -- password used to login
 lib_password VARCHAR(50) NOT NULL
);


DROP TABLE IF EXISTS employee;
-- Represents someone who works at a library in the library system
-- All employees have a user id
CREATE TABLE employee
 (
    employee_id INT PRIMARY KEY NOT NULL,
    hire_date DATE,
    salary INT,
    job_role VARCHAR(50),  
    
    -- The user account of the employee
    user_id INT,
     CONSTRAINT FK_employee_user
        FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
   
    -- The ID of the library where this employee works
   library_id INT,
     CONSTRAINT FK_employee_lib
        FOREIGN KEY (library_id) REFERENCES library(library_id)
        ON UPDATE CASCADE ON DELETE CASCADE
 );
 

 
 DROP TABLE IF EXISTS bookcase;
 -- Represents an entire bookcase, with bookshelfs, in a library branch
 CREATE TABLE bookcase
 (
  bookcase_id INT PRIMARY KEY NOT NULL,
  -- The local id used to locate the bookcase inside of a branch
  bookcase_local_num INT NOT NULL,
  -- The min and max dewey decimal number on this shelf
  dewey_max FLOAT NOT NULL,
  dewey_min FLOAT NOT NULL,
  
  -- What library is this bookcase in?
  library_id INT,
     CONSTRAINT FK_bookcase_lib
        FOREIGN KEY (library_id) REFERENCES library(library_id)
        ON UPDATE CASCADE ON DELETE CASCADE
  
 );
 
 
  DROP TABLE IF EXISTS bookshelf;
 -- Represents a bookshelf in a library branch
 CREATE TABLE bookshelf
 (
  bookshelf_id INT PRIMARY KEY NOT NULL,
  -- The min and max dewey decimal number on this shelf
  dewey_max FLOAT NOT NULL,
  dewey_min FLOAT NOT NULL,
  -- the local id used to find where a shelf is in a branch
  bookshelf_local_num INT,
  
  -- What bookcase is this shelf on
  bookcase_id INT,
    CONSTRAINT FK_bookshelf_bookcase
        FOREIGN KEY (bookcase_id) REFERENCES bookcase(bookcase_id)
        ON UPDATE CASCADE ON DELETE CASCADE        
 );
 
 DROP TABLE IF EXISTS book;
 -- Represents a book in the library system
 CREATE TABLE book 
 (
  book_id INT PRIMARY KEY NOT NULL,
  isbn INT NOT NULL,
  title VARCHAR(200) NOT NULL,
  author VARCHAR(100) NOT NULL,
  publisher VARCHAR(100),
  is_audio_book BOOL NOT NULL,
  num_pages INT,
  checkout_length_days INT,
  -- the late fee that accumulate every day past the due date
  late_fee_per_day FLOAT NOT NULL DEFAULT 0.5,
 
 -- The employee ID of who loaned out this book
  loaned_by INT,
    CONSTRAINT FK_book_employee
        FOREIGN KEY (loaned_by) REFERENCES employee(employee_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
        
    -- What bookshelf is this book on
    bookshelf_id INT,
     CONSTRAINT FK_book_bookshelf
            FOREIGN KEY (bookshelf_id) REFERENCES bookshelf(bookshelf_id)
            ON UPDATE CASCADE ON DELETE CASCADE
 );
 
-- Represents a hold on a book
-- DROP TABLE IF EXISTS holds;
CREATE TABLE holds
(
 hold_id INT PRIMARY KEY NOT NULL,
 -- ID of book being put on hold
 book_id INT NOT NULL,
 -- ID of user who placed hold
 user_id INT NOT NULL,
 hold_start_date DATE NOT NULL,
 
 -- The book on hold
 CONSTRAINT FK_hold_book
    FOREIGN KEY (book_id) REFERENCES book(book_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
-- The user placing the hold    
 CONSTRAINT FK_hold_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);



-- DROP TABLE IF EXISTS user_reg;
-- What library branch did a user register at?
CREATE TABLE user_register
(
 user_id INT NOT NULL,
 library_id INT NOT NULL,
    
 CONSTRAINT FK_register_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    
 CONSTRAINT FK_register_library
    FOREIGN KEY (library_id) REFERENCES library(library_id)
    ON UPDATE CASCADE ON DELETE CASCADE 
);


-- DROP TABLE IF EXSITS checked_out_books;
-- Represents the relationship of a user borrowing a book
CREATE TABLE checked_out_books
(
 -- what user checked out the book?
 user_id INT NOT NULL,
 -- what book is checked out?
 book_id INT NOT NULL,
 -- date book is checked out
 checkout_date DATE NOT NULL,
 
 -- The due date is found by adding the checkout length from book to checkout_date
 
 -- to the date checked out
  CONSTRAINT FK_checked_out_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    
 CONSTRAINT FK_checked_out_book
    FOREIGN KEY (book_id) REFERENCES book(book_id)
    ON UPDATE CASCADE ON DELETE CASCADE 
);

-- DROP TABLE IF EXISTS user_hist;
-- Table representing the library history of users
CREATE TABLE user_hist
(
 loan_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
 -- the user who checked out the book
 user_id INT NOT NULL,
 -- the book they checked out
 book_borrowed INT NOT NULL,
  -- what library is the book checked out from?
 library_id INT NOT NULL,
 date_borrowed DATE NOT NULL,
 date_returned DATE,

 
 CONSTRAINT FK_hist_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

CONSTRAINT FK_hist_book
    FOREIGN KEY (book_borrowed) REFERENCES book(book_id)
    ON UPDATE CASCADE ON DELETE CASCADE,    
   
CONSTRAINT FK_hist_library
    FOREIGN KEY (library_id) REFERENCES library(library_id)
    ON UPDATE CASCADE ON DELETE CASCADE 
);


-- PROCEDURES
-- take book title, give back copies available, number of holds, library it is at

-- search_for_available
-- WIP, these will be used to get the exact library each book is located at
    -- gets bookcase_id given a bookshelf_id from a book
    -- The way this is set up, it will get the bookcases of only AVAILABLE books!
   -- bc_locator AS(
 --  SELECT bookcase_id, copies_all.book_id AS book_id FROM bookshelf, copies_all 
 --   WHERE (bookshelf.bookshelf_id = copies_all.bookshelf_id)),
    
   -- gets library_id given a bookcase_id from a book 
 --  lib_locator AS(
--    SELECT library_id, bc_locator.book_id AS book_id FROM bookcase, bc_locator
 --    WHERE (bc_locator.bookcase_id = bookcase.library_id)),



-- Takes book title, returns # of copies available, # checked out, and # on hold
DELIMITER $$
CREATE PROCEDURE available_hold_count(IN booktitle_p VARCHAR(50))
BEGIN
  WITH 
  -- all copies of this book in the system
  copies_all AS(
   SELECT book_id FROM book 
    WHERE (title = booktitle_p)),
  
  -- all copies that are checked out
  copies_checked_out AS(
   SELECT book_id FROM checked_out_books 
     WHERE book_id IN (SELECT * FROM all_copies)),
    
    -- all books in the system that are NOT checked out
  num_copies_available AS(
   SELECT count(*) AS Number_Available FROM copies_all 
    WHERE (book_id.copies_all NOT IN (SELECT * FROM copies_checked_out))),
    
-- number of copies that are checked out
  num_copies_checked_out AS(
   SELECT count(*) AS Number_Checked_Out FROM checked_out_books 
     WHERE book_id IN (SELECT * FROM all_copies)),
     
-- number of copies that are on hold
  num_copies_on_hold AS(
   SELECT count(*) AS Number_On_Hold FROM holds 
     WHERE (holds.book_id = (SELECT * FROM copies_ALL LIMIT 1)))
   
   SELECT Number_Available, Number_Checked_Out, Number_On_Hold
    FROM num_copies_available, num_copies_checked_out, num_copies_on_hold;
   
END $$
-- resets the DELIMETER
DELIMITER ;


-- Given a username, returns true (1) if username is not currently used
-- false (0) if not used
DELIMITER $$
CREATE PROCEDURE does_username_exist(IN username_p VARCHAR(50))
BEGIN
   SELECT EXISTS(SELECT username FROM lib_user WHERE (username = username_p));
END $$
-- resets the DELIMETER
DELIMITER ;


-- Given a username, gets their password. 
-- Used to check if login is valid
DELIMITER $$
CREATE PROCEDURE get_user_pass(IN username_p VARCHAR(50))
BEGIN
    SELECT lib_password FROM lib_user WHERE (username = username_p);
END $$
-- resets the DELIMETER
DELIMITER ;



-- Given a username, grabs user_id
DELIMITER $$
CREATE PROCEDURE get_user_id(IN username_p VARCHAR(50))
BEGIN
    SELECT user_id FROM lib_user WHERE (username = username_p);
END $$
-- resets the DELIMETER
DELIMITER ;
-- CALL get_user_id(1);

DELIMITER $$
CREATE PROCEDURE insert_user(
  IN fname VARCHAR(50),
  IN lname VARCHAR(50),
  IN dob DATE,
  IN is_employee BOOLEAN,
  IN username VARCHAR(50),
  IN pwd VARCHAR(50)
) BEGIN
  INSERT INTO lib_user (user_id, first_name, last_name, dob, num_borrowed, is_employee, username, lib_password)
  -- user_id is auto increment, so specify default behavior
  -- hash the password with MD5 & only ever do checks on the hash
  VALUES(DEFAULT, fname, lname, dob, 0, is_employee, username, MD5(pwd));
END $$
-- resets the DELIMETER
DELIMITER ;


-- password is stored in MD5 hash so have to hash given password to check against db
DELIMITER $$
CREATE PROCEDURE check_password(IN username VARCHAR(50), IN pwd VARCHAR(50))
BEGIN
  -- insert into @hash_pwd exec get_user_pass username;
  -- SELECT lib_password FROM lib_user WHERE (username = username_p);
  DECLARE is_pwd_match BOOLEAN;
  DECLARE hashed_pwd VARCHAR(50);

  SET hashed_pwd = (
    SELECT lib_password FROM lib_user WHERE (username = username_p)
  );

  SET is_pwd_match = @hashed_pwd = MD5(pwd);
  SELECT is_pwd_match;
END $$
-- resets the DELIMETER
DELIMITER ;
