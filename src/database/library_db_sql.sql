-- Project Code 
-- Last Updated: 2021/11/17 

DROP DATABASE IF EXISTS libsystem;

CREATE DATABASE IF NOT EXISTS libSystem;
USE libSystem; 

DROP TABLE IF EXISTS library_system;
-- The library system (such as all libraries in 1 city)
CREATE TABLE library_system
 (
    library_sys_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    library_sys_name VARCHAR(100)
 ); 

DROP TABLE IF EXISTS library;
 -- Represents a library branch in the system
 CREATE TABLE library
 (
  library_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  library_system INT NOT NULL,
  library_name VARCHAR(100) NOT NULL,
  address VARCHAR(100),
  -- Simplifying the process to weekday times
  start_time_of_operation time,
  end_time_of_operation time,
  -- how many books can an individual check out of THIS branch at one time
  -- The default is 1 book per user
  max_concurrently_borrowed INT NOT NULL DEFAULT 1,
  
  -- What library system does this branch belong to
  CONSTRAINT FK_lib_system
        FOREIGN KEY (library_system) REFERENCES library_system(library_sys_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT
 );
 

-- matches lib_card_id to pregenerated UNIQUE card numbers
DROP TABLE IF EXISTS lib_cards;
CREATE TABLE lib_cards
(
 -- library card numbers are usually 14 digits long
 -- (but maybe in some systems it might not be and would make this schema not work)
 -- if wanted to impose limit: check (lib_card_id between 0 and 99999999999999)
  lib_card_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  lib_card_num INT NOT NULL UNIQUE
);
 
 DROP TABLE IF EXISTS lib_user;
-- A user in the library system
CREATE TABLE lib_user
(
 user_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL AUTO_INCREMENT,
 first_name VARCHAR(50) NOT NULL,
 last_name VARCHAR(50) NOT NULL,
 dob DATE NOT NULL,
 -- number of books the user has checked out
 num_borrowed INT,
 -- is this user an account of an employee?
 is_employee boolean DEFAULT FALSE,
 
 -- username used to login
 username VARCHAR(50) NOT NULL UNIQUE,
 -- password used to login
 lib_password VARCHAR(50) NOT NULL,
 
 -- the id of the user's library card, a 14 digit number

 -- with leading zeros (or ignore them in database and handle in procedures)
 lib_card_id INT NOT NULL,
 CONSTRAINT lib_card_id_fk
    FOREIGN KEY (lib_card_id)
    REFERENCES lib_cards(lib_card_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

DROP TABLE IF EXISTS employee;
-- Represents someone who works at a library in the library system
-- All employees have a user id
CREATE TABLE employee
 (
    employee_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
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
  bookcase_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
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
  bookshelf_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
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
  book_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  isbn VARCHAR(75) NOT NULL,
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

-- Lists the library branch where each available copy of a book is located
DELIMITER $$
CREATE PROCEDURE search_for_book(IN booktitle_p VARCHAR(50), IN lib_sys_id_p INT)
BEGIN
-- This cannot be a function because a table is returned
 WITH
   -- all copies of this book in the system with their shelf_id, case_id, local shelf/case id, lib_id
  all_copies AS(
   SELECT book.book_id, library.library_name, library.library_id, bookcase.bookcase_local_num, bookshelf.bookshelf_local_num,
    bookcase.bookcase_id, bookshelf.bookshelf_id, COUNT(*) AS num_copies_at_library
   FROM book
   JOIN bookshelf ON book.bookshelf_id = bookshelf.bookshelf_id
   JOIN bookcase ON bookshelf.bookcase_id = bookcase.bookcase_id
   JOIN library ON bookcase.library_id = library.library_id
   WHERE (title = booktitle_p AND lib_sys_id_p = library.library_system)
   GROUP BY library.library_id),

  -- Get the Copies that are checked out at a given library
  num_copies_taken AS(
    SELECT all_copies.book_id, all_copies.library_id, COUNT(checked_out_books.book_id) AS num_checked_out
    FROM all_copies
    LEFT OUTER JOIN checked_out_books ON checked_out_books.book_id = all_copies.book_id
    GROUP BY all_copies.library_id
  ),
  
  -- Get the number of holds 
  num_copies_available AS(
    SELECT all_copies.*, num_copies_taken.num_checked_out,
        (all_copies.num_copies_at_library - num_copies_taken.num_checked_out) AS num_copies_in_stock
    FROM all_copies
    LEFT OUTER JOIN num_copies_taken 
    ON all_copies.book_id = num_copies_taken.book_id
  ),
  
  -- Find how many holds there are for the book at each library
  num_holds AS(
    SELECT num_copies_available.*, COUNT(holds.book_id) AS number_holds
        FROM num_copies_available
        LEFT OUTER JOIN holds
        ON num_copies_available.book_id = holds.book_id
        GROUP BY num_copies_available.book_id
  )
  
  SELECT book_id, library_name, library_id, bookcase_local_num, bookshelf_local_num,
    bookcase_id, bookshelf_id, num_copies_at_library, num_checked_out, num_copies_in_stock, number_holds
    FROM num_holds;

 
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
CREATE FUNCTION get_user_id(username_p VARCHAR(50))
 RETURNS INT 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE found_user_id INT;
    SELECT user_id INTO found_user_id FROM lib_user WHERE (username = username_p) LIMIT 1;
    RETURN (found_user_id);
END $$
-- resets the DELIMETER
DELIMITER ;
-- SELECT get_user_id(1);


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
DROP PROCEDURE IF EXISTS insert_user;
DELIMITER $$
CREATE PROCEDURE insert_user(
  IN fname VARCHAR(50),
  IN lname VARCHAR(50),
  -- In python, call a procedure to get the library id given its name
  IN in_library_id INT,
  IN dob DATE,
  IN is_employee BOOLEAN,
  IN username VARCHAR(50),
  IN pwd VARCHAR(50)
) BEGIN
  DECLARE new_user_id INT;
  -- in case insert into lib_user fails, start a transaction that can rollback other insertions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
      ROLLBACK;
  END;
  START TRANSACTION;

  -- create new library card number based on existing
  SET new_lib_card_num = (
    -- coalesce handles if no entries in table yet and max is null
    SELECT coalesce(MAX(lib_card_num)+1, 0)
    FROM lib_cards
  );

  -- insert into library card (and get its id)
  INSERT INTO lib_cards (lib_card_id, lib_card_num) VALUES (DEFAULT, new_lib_card_num);
  SET new_lib_card_id = LAST_INSERT_ID(); -- get id of last inserted row into a table

  -- insert into lib_user
  INSERT INTO lib_user (user_id, first_name, last_name, dob, num_borrowed, is_employee, username, lib_password, lib_card_id)
  -- user_id is auto increment, so specify default behavior
  -- hash the password with MD5 & only ever do checks on the hash (no plaintext passwords)
  VALUES(DEFAULT, fname, lname, dob, 0, is_employee, username, MD5(pwd), new_lib_card_id);
  SET new_user_id = LAST_INSERT_ID();
  
  -- insert into user_register
  INSERT INTO user_register (user_id, library_id) VALUES(new_user_id, in_library_id);
  COMMIT

END $$
-- resets the DELIMETER
DELIMITER ;

-- call insert_user("testfname", "testlname", curdate(), True, "testusername", "testpwd");
-- call insert_user("testfname", "testlname", curdate(), True, "testusername", "testpwd"); -- will fail bc usernames MUST be unique

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

DELIMITER //
CREATE FUNCTION get_bookshelf_from_dewey (in_dewey_num FLOAT, in_lib_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE correct_case_id INT;
    DECLARE shelf_id_for_dewey INT;
    -- Get the bookcase in the library that fits the dewey number
    SELECT bookcase_id INTO correct_case_id
        FROM bookcase 
        WHERE library_id = in_lib_id 
            AND in_dewey_num >= dewey_min 
            AND in_dewey_num <= dewey_max;
                
    -- Get the specific shelf within that case that works for the given dewey number
    SELECT bookshelf_id INTO shelf_id_for_dewey
        FROM bookshelf
        WHERE bookcase_id = correct_case_id
            AND in_dewey_num >= dewey_min 
            AND in_dewey_num <= dewey_max
        -- Put it in the lowest possible shelf
        ORDER BY bookcase_id ASC
        LIMIT 1;
    
    return (shelf_id_for_dewey);
END //


DELIMITER $$
CREATE PROCEDURE add_new_book(IN in_title VARCHAR(200),
    -- PRECONDITION: backend code uses get_users_lib_id to get their library_id BEFORE this procedure
    IN in_lib_id INT,
    IN in_isbn VARCHAR(75),
    IN in_author VARCHAR(100),
    IN in_publisher VARCHAR(100),
    IN in_is_audio_book BOOL,
    IN in_num_pages INT,
    IN in_checkout_length_days INT,
    IN in_book_dewey FLOAT,
    IN in_late_fee_per_day FLOAT)
BEGIN
    DECLARE placement_bookshelf_id INT;
    -- Using the dewey number of the book, puts it in the right bookshelf + bookshelf
    -- NOTE: in a lot of cases the Dewey Number is an estimate. 
    -- Real data domain experts would be needed to provide the exact dewey numbers
    -- Reference: https://www.britannica.com/science/Dewey-Decimal-Classification 
    -- Reference (through searching each book): https://catalog.loc.gov/vwebv/ui/en_US/htdocs/help/numbers.html
    SET placement_bookshelf_id = (SELECT get_bookshelf_from_dewey(in_book_dewey, in_lib_id) );
    
    INSERT INTO book (isbn, title, author, publisher, is_audio_book, 
        num_pages, checkout_length_days, late_fee_per_day, bookshelf_id)
    VALUES(in_isbn, in_title, in_author, in_publisher, in_is_audio_book, 
        in_num_pages, in_checkout_length_days, in_late_fee_per_day, placement_bookshelf_id);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE add_bookcase(IN in_library_id INT,
    IN in_dewey_min FLOAT,
    IN in_dewey_max FLOAT)
BEGIN
    -- Get the current highest bookcase number for the library - use the next value
    DECLARE next_bookcase_local_num INT;

     SET next_bookcase_local_num  = (
        -- If a library doesnt have any bookshelves, max is null. this will have the result be a 0 instead of NULL.
        SELECT COALESCE(MAX(bookcase_local_num) + 1, 0)
        FROM bookcase
        WHERE library_id = in_library_id
        );
    
    -- insert the new book case
    INSERT INTO bookcase (bookcase_local_num, dewey_max, dewey_min, library_id)
        VALUES (next_bookcase_local_num, in_dewey_max, in_dewey_min, in_library_id);
END $$
-- resets the DELIMETER
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE add_bookshelf(IN in_library_id INT,
    IN in_dewey_min FLOAT,
    IN in_dewey_max FLOAT)
BEGIN
    -- Get the current highest bookshelf number for the library - use the next value
    DECLARE next_bookshelf_local_num INT;
    DECLARE referenced_bookcase_id INT;
    
    SET next_bookshelf_local_num = (
        -- If a library doesnt have any bookshelves, max is null. 
        -- This will have the result be a 0 instead of NULL.
        SELECT COALESCE(MAX(get_shelfs_in_lib.bookshelf_local_num) + 1, 0)
        -- Get the shelfs in the library
        FROM (
            SELECT bookshelf.* FROM 
            -- Get the bookcase(s) this shelf could belong to
            (
                SELECT bookcase_id FROM bookcase WHERE library_id = in_library_id
            ) getBookcases
            -- Get all of the id's for EVERY shelf in this library (based on all of its cases)
            RIGHT JOIN bookshelf
            ON bookshelf.bookcase_id = getBookcases.bookcase_id
        ) get_shelfs_in_lib
    );

    -- pick the proper bookcase based on if the shelf's dewey range fits inside it.
    -- Can assume only 1 bookcase fits the criteria. limit to 1 just in case though.
    -- Whenever possible, put the book in the lower order book case
    SET referenced_bookcase_id = (
        SELECT getBookcasesID.bookcase_id
        FROM (
        -- Get the bookcase(s) this shelf could belong to in the library
            SELECT bookcase_id, dewey_min, dewey_max 
            FROM bookcase 
            WHERE library_id = in_library_id 
                AND in_dewey_min >= dewey_min 
                AND in_dewey_max <= dewey_max
        ORDER BY bookcase.bookcase_id DESC
        LIMIT 1
        ) getBookcasesID
    );
    
    -- insert the new bookshelf
    INSERT INTO bookshelf (dewey_max, dewey_min, bookshelf_local_num, bookcase_id)
        VALUES (in_dewey_max, in_dewey_min, next_bookshelf_local_num, referenced_bookcase_id);
END $$
-- resets the DELIMETER
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE add_library(IN in_library_system_name VARCHAR(100),
    IN in_library_name VARCHAR(100),
    IN in_address VARCHAR(100),
    IN in_start_time_of_operation time,
    IN in_end_time_of_operation time,
    IN in_max_concurrently_borrowed INT)
BEGIN
    -- Get the id of the library system that this new library belongs to 
    DECLARE var_library_sys_id INT;
    SET var_library_sys_id = (
         SELECT library_sys_id
            FROM library_system
            WHERE library_sys_name = in_library_system_name
            LIMIT 1
        );
    
    -- Insert the given values into the table
     INSERT INTO library (library_system, 
            library_name, 
            address,
            start_time_of_operation, 
            end_time_of_operation, 
            max_concurrently_borrowed)
     VALUES (var_library_sys_id, in_library_name, in_address, in_start_time_of_operation, 
        in_end_time_of_operation, in_max_concurrently_borrowed);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_users_lib_id(in_user_id INT)
 RETURNS INT 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE library_id_out INT;
    -- GIVEN: a user's id, return the id of the library they belong to
  
  -- The backend side will have the user's id,
  -- so this procedure makes it very easy to get the library they belong to
  SELECT library_id INTO library_id_out
    FROM user_register
    WHERE in_user_id = user_id;
    
    RETURN(library_id_out);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_id_from_name(in_lib_name VARCHAR(100), in_lib_sys_name VARCHAR(100))
 RETURNS INT 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE library_id_out INT;
    -- GIVEN: a user's id, return the id of the library they belong to
  
  -- The backend side will have the user's id,
  -- so this procedure makes it very easy to get the library they belong to
  SELECT library_id INTO library_id_out
    FROM library
    WHERE library_name = in_lib_name /*AND in_lib_sys_name = library_system*/;
    
    RETURN(library_id_out);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_libraries()
BEGIN
  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_id, library_name FROM library;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_library_systems()
BEGIN
  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_sys_id, library_sys_name FROM library_system;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION is_lib_in_sys(in_lib_name VARCHAR(100), in_lib_sys_name VARCHAR(100))
 RETURNS BOOL 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library name and system, return 1 if the library is in the system
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret 
        FROM library_system
        INNER JOIN library
        ON library.library_system = library_system.library_sys_id
        WHERE 
            in_lib_sys_name = library_system.library_sys_name 
            AND 
            library.library_name = in_lib_name;
    
    RETURN(ret);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION is_a_lib_sys(in_lib_sys_name VARCHAR(100))
 RETURNS BOOL 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library system name, return 1 if it exists
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret 
        FROM library_system
        WHERE in_lib_sys_name = library_system.library_sys_name;
    
    RETURN(ret);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_sys_id_from_user_id(in_user_id INT)
 RETURNS BOOL 
 DETERMINISTIC 
 READS SQL DATA
BEGIN
    DECLARE lib_sys_id BOOL;
    -- GIVEN a user's id, returns the id of the library system 
    SELECT library_system INTO lib_sys_id
        FROM library
        WHERE library_id = (
            SELECT library_id
            FROM user_register
            WHERE user_id = in_user_id
            LIMIT 1
        );
    
    RETURN(lib_sys_id);
END $$
-- resets the DELIMETER
DELIMITER ;

-- ######## CALL SCRIPTS TO ADD DATA TO DATABASE
-- Taken from the add_test_data/ scripts
-- ##### ADD Library Systems ####
INSERT INTO library_system (library_sys_name) VALUES
    ("Metro Boston Library Network"),
    ("Old Colony Library Network"),
    ("Minuteman Library Network");

-- ##### ADD Library's ####
-- Add a few libraries. Have 5 libraries spread across 2 library systems.

-- Metro Boston Library locations come from here:
-- https://bpl.bibliocommons.com/locations/
-- Simplifying hours of operation to weekdays
CALL add_library("Metro Boston Library Network", "Charlestown",
        "179 Main St Charlestown, MA 02129", '10:00', '18:00', 5);
CALL add_library("Metro Boston Library Network", "Central Library in Copley Square",
        "700 Boylston Street Boston, MA 02116", '10:00', '8:00', 5);
CALL add_library("Metro Boston Library Network", "Jamaica Plain",
        "30 South Street Jamaica Plain, MA 02130", '10:00', '6:00', 5);
-- Reference: https://catalog.ocln.org/client/en_US/ocln/?rm=LIBRARY+LOCATI1%7C%7C%7C1%7C%7C%7C3%7C%7C%7Ctrue
CALL add_library("Old Colony Library Network", "Plymouth Public Library",
        "132 South Street Plymouth, MA 02360", '10:00', '9:00', 8);
CALL add_library("Old Colony Library Network", "Kingston Public Library",
        "6 Green Street Kingston, MA 02364", '10:00', '5:00', 4);

-- ##### ADD BOOKCASES AND BOOKSHELVES ####
CALL add_bookcase(1, 000, 999);
CALL add_bookshelf(1, 000, 499);
CALL add_bookshelf(1, 500, 999);

-- Make central library have 2 book cases. Each has multiple shelves.
CALL add_bookcase(2, 0, 499);
CALL add_bookshelf(2, 0, 299);
CALL add_bookshelf(2, 300, 399);
CALL add_bookshelf(2, 400, 499);
CALL add_bookcase(2, 500, 999);
CALL add_bookshelf(2, 500, 750);
CALL add_bookshelf(2, 751, 999);

CALL add_bookcase(3, 0, 999);
CALL add_bookshelf(3, 0, 199);
CALL add_bookshelf(3, 200, 399);
CALL add_bookshelf(3, 400, 599);
CALL add_bookshelf(3, 600, 999);

CALL add_bookcase(4, 0, 999);
CALL add_bookshelf(4, 0, 499);
CALL add_bookshelf(4, 500, 999);

CALL add_bookcase(5, 0, 999);
CALL add_bookshelf(5, 0, 599);
CALL add_bookshelf(5, 600, 999);

-- ##### ADD A User & Employee ####
CALL insert_user("employee",
  "dummy",
  1,
  CURDATE(),
  true,
  "test_employee",
  "fakePWD1234");
  
  CALL insert_user("employee2",
  "dummy2",
  2,
  CURDATE(),
  true,
  "test_employee2",
  "fakePWD1234");
  
-- ##### ADD some BOOKS ####
  CALL add_new_book("Database Systems - A Practical Approach to Design, Implementation, and Management",
    -- This only works bc custom data, change eventually
    1, "978-0-13-294326-0", "Thomas Connolly and Carolyn Begg", "Pearson",
    false, 1442, 14, 005.74, .5);

-- have Moby Dick be in 2 libraries in the same system (make the lib id be 1 and 2)
CALL add_new_book("Moby Dick", 1, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 14, 812.54, .5);
-- Have 2 copies of the same book in 1 library
CALL add_new_book("Moby Dick", 1, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 14, 812.54, .5);
CALL add_new_book("Moby Dick", 2, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 14, 812.54, .5);

-- Also put Moby Dick in another system to test the search results - 4 is start of new system
CALL add_new_book("Moby Dick", 4, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 14, 812.54, .5);