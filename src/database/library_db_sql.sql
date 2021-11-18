-- Project Code 
-- Last Updated: 2021/11/17 

DROP DATABASE IF EXISTS libsystem;

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
 user_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
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
 
 -- the id of the user's library card, a 14 digit number
 -- lib_card_id INT NOT NULL
 
 -- TODO, determine how to format the lib_card_id to always be 14 digits long
 -- with leading zeros

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
  -- the dewey decimal number of the book
  book_dewey FLOAT NOT NULL,
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
DROP TABLE IF EXISTS holds;
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



DROP TABLE IF EXISTS user_reg;
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


DROP TABLE IF EXISTS checked_out_books;
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

DROP TABLE IF EXISTS user_hist;
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
 date_returned DATE DEFAULT NULL,

 
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

--
-- FUNCTIONS
--

-- Given a book_id, returns the library_id of where it is located
DELIMITER $$
CREATE FUNCTION library_id_from_book(book_id_p INT)
 RETURNS INT 
 DETERMINISTIC 
 READS SQL DATA
BEGIN 
 DECLARE library_id_out INT;
 WITH desired_book AS(
   SELECT * FROM book 
    WHERE (book_id = book_id_p)),

 -- joining the desired_book and bookcase_id from bookshelf table
  desired_book_bs AS (
  SELECT title, desired_book.bookshelf_id, bookshelf.bookcase_id 
   FROM desired_book JOIN bookshelf
   USING (bookshelf_id)),
   
   -- joining desired_book_bs and library_name/ library_id from library table
   desired_book_lib AS (
   SELECT desired_book_bs.title, desired_book_bs.bookshelf_id, 
            desired_book_bs.bookcase_id,
            library.library_name,
            library.library_id
    FROM desired_book_bs JOIN library
    USING (library_id))
    
    SELECT library_id INTO library_id_out FROM desired_book_lib;
 
 RETURN(library_id_out);
END $$
DELIMITER ;


--
-- PROCEDURES
--

-- Takes book title, returns # of copies available, # checked out, and # on hold
DELIMITER $$
CREATE PROCEDURE available_hold_count(IN booktitle_p VARCHAR(50))
BEGIN
  WITH 
  -- the book title 
  b_title AS(
   SELECT title FROM book 
    WHERE (title = booktitle_p)),
  
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
   
   SELECT b_title.title, Number_Available, Number_Checked_Out, Number_On_Hold
    FROM b_title, num_copies_available, num_copies_checked_out, num_copies_on_hold;
   
END $$
-- resets the DELIMETER
DELIMITER ;

-- Lists the library branch where each available copy of a book is located
DELIMITER $$
CREATE PROCEDURE get_book_location(IN booktitle_p VARCHAR(50))
BEGIN
 WITH 
   -- all copies of this book in the system
  copies_all AS(
   SELECT * FROM book 
    WHERE (title = booktitle_p)),
  
  -- all copies that are checked out
  copies_checked_out AS(
   SELECT * FROM checked_out_books 
     WHERE book_id IN (SELECT * FROM all_copies)),
 
 -- all books in the system that are NOT checked out
   copies_available AS(
   SELECT * FROM copies_all 
    WHERE (book_id.copies_all NOT IN (SELECT * FROM copies_checked_out))),
 
 
 -- This is redundant, but I don't want to delete it in case I need it later
 -- The bookcase that a bookshelf is on
 --   bookshelf_loc AS (
 --   SELECT bookcase_id FROM bookshelf
 --    WHERE (bookshelf.booksheld_id IN (SELECT * FROM copies_available))),
    
 -- The library that a bookcase in in
 -- lib_loc AS (
 --  SELECT library_id, library_name FROM library
 --   WHERE (library.library_id IN (SELECT * FROM bookshelf_loc))),
 
 -- joining the copies_available and bookcase_id from bookshelf table
  copies_available_bs AS (
  SELECT title, copies_available.bookshelf_id, bookshelf.bookcase_id 
   FROM copies_available JOIN bookshelf
   USING (bookshelf_id)),
   
   -- joining copies_available_bs and library name from library table
   copies_available_lib AS (
   SELECT copies_available_bs.title, copies_available_bs.bookshelf_id, 
            copies_available_bs.bookcase_id,
            library.library_name
    FROM copies_available_bs JOIN library
    USING (library_id))
 
 -- This should contain the book title, the bookshelf_id, bookcase_id, and library name
 -- of the available copies of the desired book
 SELECT * FROM copies_available_lib;
END $$
-- resets the DELIMETER
DELIMITER ;


-- checking out a book given a book_id and user_id
-- Adds the book to the "checked out book" table, 
-- returns the due date
-- Adds book to the user's history
DELIMITER $$
CREATE PROCEDURE check_out(IN book_id_p INT, IN user_id_p INT)
BEGIN
 DECLARE checkout_length_days INT;
 DECLARE library_book_ID INT;
 
 
 SET checkout_length_days = 
   (SELECT checkout_length_days FROM book 
    WHERE book_id = book_id_p);
  
  -- Adds the book to the check_out_books table
   INSERT INTO checked_out_books
   VALUES (user_id_p, book_id_p, now());
   
   -- The due date of the book is:
   SELECT DATE(CURDATE() + checkout_length_days) AS "The book is due: ";
 
 SET library_book_ID = (
    SELECT library_id FROM library
    WHERE library.library_id IN 
    (SELECT bookcase_id FROM bookshelf
     WHERE (bookshelf.booksheld_id IN (SELECT * FROM book WHERE book_id = book_id_p))));
 
   -- Adding the checkout into the user_hist table
   INSERT INTO user_hist
   VALUES (DEFAULT, user_id_p, book_id_p, library_book_ID, 
        now(), DEFAULT);
END $$
-- resets the DELIMETER
DELIMITER ;


-- Procedure to place a hold for a book
-- will put a hold on the copy of the book that has been checked out the longest
DELIMITER $$
CREATE PROCEDURE place_hold(IN user_id_p INT, IN title_p VARCHAR(200))
BEGIN 
-- get the copy of book in checked_out_books that has been out the longest
-- make a hold with that book and user date

INSERT INTO holds
    VALUES (DEFAULT, 
        -- the book_id of the book that has been checked out the longest
            (SELECT book_id FROM checked_out_books 
             WHERE (title_p = title)
             ORDER BY checkout_date ASC 
             LIMIT 1)
            , user_id_p,
            now());
END $$
-- resets the DELIMETER
DELIMITER ;

-- returns a book to the library
DELIMITER $$
CREATE PROCEDURE return_book(IN book_id_p INT, IN user_id_p INT)
BEGIN
DECLARE book_library_id INT;
-- A function to get the library_id for a specific book
SELECT library_id_from_book(book_id_P) INTO book_library_id;


 -- Adds the return date to the user_Hist
UPDATE user_hist
 SET date_returned = now()
 WHERE ((user_id_p = user_id) AND 
        (book_id_p = book_id));
 
 -- Delete row from checked_out_Books
 DELETE FROM checked_out_books 
  WHERE ((user_id_p = user_id) AND 
        (book_id_p = book_id));
 -- TODO how to handle a user who has placed a hold on the book being checked in
 -- SELECT * FROM holds WHERE (book_id_p = 
 
 -- Checks out the book for the next person on hold, if one exists 
 -- Otherwise, the book is return and ready to be checked out by whomever else wants it
 IF EXISTS (SELECT * FROM holds where (book_id_p = book_id)) THEN
     INSERT INTO checked_out_books 
     VALUES ((SELECT user_id FROM holds 
                WHERE (book_id_p = book_id) 
                ORDER BY hold_start_date ASC LIMIT 1)
            , book_id_p, now());
      
      -- Updates user_hist 
    INSERT INTO user_hist
    VALUES (DEFAULT, 
            (SELECT user_id FROM holds 
                WHERE (book_id_p = book_id) 
                ORDER BY hold_start_date ASC LIMIT 1)
            , book_id_p, book_library_id
    , now(), null);
  
 -- We will register the user to whatever copy of the book that has been checked out
 -- for the longest period of time, assuming that it will be the next copy returned
 END IF;
END $$
-- resets the DELIMETER
DELIMITER ;


-- Given a username, returns true (1) if username is not currently used
-- false (0) if not used
DELIMITER $$
CREATE PROCEDURE does_username_exist(IN username_p VARCHAR(50))
BEGIN
   SELECT EXISTS(SELECT username FROM lib_user WHERE (username = username_p)) AS username_exists;
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


-- Do I need to hash this?
-- updates a user's password
DELIMITER $$
CREATE PROCEDURE update_pwd(IN username_p VARCHAR(50), IN pwd_p VARCHAR(50))
BEGIN
 UPDATE lib_user
 SET lib_password = MD5(pwd_p)
 WHERE username = username_p;
END $$
-- resets the DELIMETER
DELIMITER ;


-- Inserts a new user into the DB
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
CREATE PROCEDURE check_password(IN username_to_test VARCHAR(50), IN pwd VARCHAR(50))
BEGIN
  -- insert into @hash_pwd exec get_user_pass username;
  -- SELECT lib_password FROM lib_user WHERE (username = username_p);
  DECLARE is_pwd_match BOOLEAN;
  DECLARE hashed_pwd VARCHAR(50);

  SET hashed_pwd = (
    SELECT lib_password FROM lib_user WHERE (username = username_to_test)
  );

  SET is_pwd_match = hashed_pwd = MD5(pwd);
  SELECT is_pwd_match;
END $$
-- resets the DELIMETER
DELIMITER ;
