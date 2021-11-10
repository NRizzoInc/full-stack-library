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


-- DROP TABLE IF EXISTS book_return;
-- Represents a user returning a book to a library branch
CREATE TABLE book_return
(
 -- used to log return info in user_history
 return_id INT PRIMARY KEY NOT NULL,
 -- what user returned out the book?
 user_id INT NOT NULL,
 -- what book is returned out?
 book_id INT NOT NULL,
 -- what library is the book returned to?
 library_id INT NOT NULL,
 -- date book is returned out
 return_date DATE NOT NULL,
 
  CONSTRAINT FK_book_return_book
    FOREIGN KEY (book_id) REFERENCES book(book_id)
    ON UPDATE CASCADE ON DELETE CASCADE, 
 
  CONSTRAINT FK_book_return_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    
 CONSTRAINT FK_book_return_library
    FOREIGN KEY (library_id) REFERENCES library(library_id)
    ON UPDATE CASCADE ON DELETE CASCADE 
);


-- DROP TABLE IF EXISTS user_hist;
-- Table representing the library history of users
CREATE TABLE user_hist
(
 loan_id INT PRIMARY KEY NOT NULL,
 -- the user who checked out the book
 user_id INT NOT NULL,
 -- the book they checked out
 book_borrowed INT NOT NULL,
 date_borrowed DATE NOT NULL,
 date_returned DATE,
 return_id INT,
 
 CONSTRAINT FK_hist_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

CONSTRAINT FK_hist_book
    FOREIGN KEY (book_borrowed) REFERENCES book(book_id)
    ON UPDATE CASCADE ON DELETE CASCADE,    
    
 CONSTRAINT FK_hist_return
    FOREIGN KEY (return_id) REFERENCES book_return(return_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);