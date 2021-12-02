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
 user_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
 -- the id of the user's library card, a 14 digit number
 lib_card_id INT NOT NULL,
 CONSTRAINT lib_card_id_fk
    FOREIGN KEY (lib_card_id)
    REFERENCES lib_cards(lib_card_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
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
 lib_password VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS employee;
-- Represents someone who works at a library in the library system
-- All employees have a user id
CREATE TABLE employee
 (
    employee_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    hire_date DATE,
    salary FLOAT,
    job_role VARCHAR(200),

    -- Used to make sure employees are APPROVED by verified employees before getting added to the system
    is_approved BOOL DEFAULT FALSE,

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
CREATE TABLE book (
  -- isbn is unique to each book (and is different between regular and audio books)
  -- ISBN can be max of 17 numbers/chars (may be alphanumeric so cant use INT)
  isbn VARCHAR(17) PRIMARY KEY NOT NULL,
  title VARCHAR(200) NOT NULL,
  author VARCHAR(100) NOT NULL,
  publisher VARCHAR(100),
  is_audio_book BOOL NOT NULL,
  num_pages INT,
  -- the dewey decimal number of the book
  book_dewey FLOAT NOT NULL
);

DROP TABLE IF EXISTS book_inventory;
CREATE TABLE book_inventory (
  book_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  isbn VARCHAR(17) NOT NULL,
  loaned_by INT,
  bookshelf_id INT,
  checkout_length_days INT,
  -- the late fee that accumulate every day past the due date
  late_fee_per_day FLOAT NOT NULL DEFAULT 0.5,
  -- The employee ID of who loaned out this book

  CONSTRAINT fk_book_isbn
    FOREIGN KEY (isbn) REFERENCES book(isbn)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT FK_book_employee
    FOREIGN KEY (loaned_by) REFERENCES employee(employee_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  -- What bookshelf is this book on
  CONSTRAINT FK_book_bookshelf
    FOREIGN KEY (bookshelf_id) REFERENCES bookshelf(bookshelf_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Represents a hold on a book
DROP TABLE IF EXISTS holds;
CREATE TABLE holds
(
  hold_id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
  -- title of book being put on hold
  isbn VARCHAR(17) NOT NULL,
  -- ID of user who placed hold
  user_id INT NOT NULL,
  lib_sys_id INT NOT NULL,
  library_id INT NOT NULL,
  hold_start_date DATETIME NOT NULL,

  -- the isbn belonging to the book on hold
  CONSTRAINT FK_hold_isbn
    FOREIGN KEY (isbn) REFERENCES book(isbn)
    ON UPDATE CASCADE ON DELETE CASCADE,

  -- The user placing the hold
  CONSTRAINT FK_hold_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT FK_hold_lib_sys
    FOREIGN KEY (lib_sys_id) REFERENCES library_system(library_sys_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT FK_hold_lib
    FOREIGN KEY (library_id) REFERENCES library(library_id)
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
 checkout_date DATETIME NOT NULL,
 -- date when book is due
 -- The due date is found by adding the checkout length from book to checkout_date
 due_date DATETIME NOT NULL,

  CONSTRAINT FK_checked_out_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

 CONSTRAINT FK_checked_out_book
    FOREIGN KEY (book_id) REFERENCES book_inventory(book_id)
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
 date_borrowed DATETIME NOT NULL,
 date_returned DATETIME DEFAULT NULL,


 CONSTRAINT FK_hist_user
    FOREIGN KEY (user_id) REFERENCES lib_user(user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

CONSTRAINT FK_hist_book
    FOREIGN KEY (book_borrowed) REFERENCES book_inventory(book_id)
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
    SELECT book_inventory.*, book.title FROM book_inventory
    JOIN book ON book.isbn = book_inventory.isbn
    WHERE book_inventory.book_id = book_id_p
  ),
 -- joining the desired_book and bookcase_id from bookshelf table
  desired_book_bs AS (
    SELECT title, bookcase.library_id, desired_book.bookshelf_id, bookshelf.bookcase_id
    FROM desired_book
    JOIN bookshelf USING (bookshelf_id)
    JOIN bookcase USING (bookcase_id)
  )

  SELECT library_id INTO library_id_out FROM desired_book_bs;

 RETURN(library_id_out);
END $$
DELIMITER ;


--
-- PROCEDURES
--

-- CALL place_hold(1, "Moby Dick", 1, 2); -- lib_id = 2 start off with only book checked out
-- CALL place_hold(2, "Moby Dick", 1, 2); -- results in 2 holds in "Central Library..." (diff users)
-- CALL place_hold(2, "Moby Dick", 1, 2); -- fails because user already has hold (same user/system)
-- CALL place_hold(2, "Moby Dick", 3, 1); -- results in 3 holds (at least 1 at each lib)
-- CALL search_for_book("Moby Dick", 1);

-- Lists the library branch where each available copy of a book is located
DROP PROCEDURE IF EXISTS search_for_book;
DELIMITER $$
CREATE PROCEDURE search_for_book(IN booktitle_p VARCHAR(200), IN lib_sys_id_p INT)
BEGIN
-- This cannot be a function because a table is returned
 DECLARE derived_isbn VARCHAR(17);
 SET derived_isbn = (SELECT isbn FROM book WHERE title = booktitle_p LIMIT 1);

 WITH
   -- all copies of this book in the system with their shelf_id, case_id, local shelf/case id, lib_id
  all_copies AS(
    SELECT
      book_inventory.book_id,
      book_inventory.isbn,
      library.library_name,
      library.library_id,
      bookcase.bookcase_local_num,
      bookshelf.bookshelf_local_num,
      bookcase.bookcase_id,
      bookshelf.bookshelf_id
    FROM book_inventory
    JOIN bookshelf ON book_inventory.bookshelf_id = bookshelf.bookshelf_id
    JOIN bookcase ON bookshelf.bookcase_id = bookcase.bookcase_id
    JOIN library ON bookcase.library_id = library.library_id
    WHERE (book_inventory.isbn = derived_isbn AND lib_sys_id_p = library.library_system)
  ),
  num_copies_exist AS(
    SELECT all_copies.library_id, count(*) as num_copies_at_library
    FROM all_copies
    GROUP BY all_copies.library_id
  ),
  num_copies_available AS(
    SELECT
      all_copies.library_id,
      COUNT(checked_out_books.book_id) as num_checked_out,
      (num_copies_exist.num_copies_at_library - COUNT(checked_out_books.book_id)) as num_copies_in_stock
    FROM all_copies
    LEFT JOIN num_copies_exist ON num_copies_exist.library_id = all_copies.library_id
    LEFT JOIN checked_out_books ON all_copies.book_id = checked_out_books.book_id
    GROUP BY all_copies.library_id
  ),
  -- Find how many holds there are for the book at each library
  relevant_holds AS (
    SELECT all_copies.*, holds.hold_id, holds.user_id
    FROM all_copies
    LEFT JOIN holds ON holds.library_id = all_copies.library_id -- AND holds.isbn = all_copies.isbn
    WHERE holds.isbn = derived_isbn
    -- multiple users at one library can have the "same" hold
    GROUP BY holds.library_id, holds.user_id
  ),
  num_holds AS(
    SELECT
      relevant_holds.library_id,
      COUNT(*) AS number_holds
    FROM relevant_holds
    GROUP BY relevant_holds.library_id
  ),
  combined_table AS (
    SELECT
      all_copies.library_id,
      all_copies.library_name,
      num_copies_exist.num_copies_at_library,
      num_copies_available.num_checked_out,
      num_copies_available.num_copies_in_stock,
      -- if no holds, may be null, replace with 0
      coalesce(num_holds.number_holds, 0) AS number_holds
    FROM all_copies
    LEFT OUTER JOIN num_copies_exist ON num_copies_exist.library_id = all_copies.library_id
    LEFT OUTER JOIN num_holds ON num_holds.library_id = all_copies.library_id
    LEFT OUTER JOIN num_copies_available ON all_copies.library_id = num_copies_available.library_id
    GROUP BY all_copies.library_id
  )

  SELECT * FROM combined_table;
END $$
DELIMITER ;


DROP FUNCTION IF EXISTS is_book_checked_out;
DELIMITER $$
CREATE FUNCTION is_book_checked_out(book_id_p INT)
 RETURNS BOOLEAN
 DETERMINISTIC
 READS SQL DATA
BEGIN
  -- must be > 0 copies available (and book_id cant be already checked out)
  DECLARE book_already_out BOOLEAN;
  SET book_already_out = (
    SELECT COUNT(*) > 0
    FROM checked_out_books
    WHERE book_id = book_id_p
    GROUP BY book_id
  );
  RETURN(book_already_out);
END $$
DELIMITER ;

DROP FUNCTION IF EXISTS is_book_avail;
DELIMITER $$
CREATE FUNCTION is_book_avail(
  book_title_p VARCHAR(200),
  lib_sys_id_p INT,
  lib_id_p INT,
  user_id_p INT
)
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
  -- returns a book_id of a copy of the book
  -- titled 'book_title_p' in the library system
  -- -1 if no book exists
  -- -2 if user already checked out book
  DECLARE book_copy_avail INT;
  SET book_copy_avail = (
    WITH rel_book_in_sys AS (
      SELECT book.title, book_inventory.book_id as rel_book_id, library.*  FROM book
      JOIN book_inventory ON book_inventory.isbn = book.isbn
      JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
      JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
      JOIN library ON library.library_id = bookcase.library_id
    ),
    avail_book_in_sys AS (
      SELECT * FROM rel_book_in_sys
      WHERE
        title = book_title_p AND
        library_system = lib_sys_id_p AND
        library_id = lib_id_p AND
        rel_book_id NOT IN (SELECT book_id FROM checked_out_books)
      LIMIT 1
    ),
    already_checked_out AS (
      SELECT * FROM rel_book_in_sys
      -- join means all rows are of "checked out" books
      JOIN checked_out_books ON checked_out_books.book_id = rel_book_id
      WHERE
        checked_out_books.user_id = user_id_p AND
        title = book_title_p AND
        library_system = lib_sys_id_p AND
        library_id = lib_id_p
    )
    SELECT (CASE
      -- if user already checked out book, count > 0 (if not select valid book_id)
      WHEN COUNT(*) > 0 THEN -2 ELSE (
        SELECT (CASE WHEN COUNT(*) > 0 THEN avail_book_in_sys.rel_book_id ELSE -1 END)
        FROM avail_book_in_sys
      ) END
    )
    FROM already_checked_out -- should be empty if none checked out already

  );

  RETURN(book_copy_avail);
END $$
DELIMITER ;



DELIMITER $$
CREATE PROCEDURE search_lib_sys_catalog(IN lib_sys_id_p INT)
BEGIN
    -- This cannot be a function because a table is returned
    -- limit the libraries to JUST libraries in the system
    WITH libs_in_sys AS (
        SELECT library_id, library_name FROM library WHERE library_system = lib_sys_id_p
    ),
    -- Overall: lib -> bookcases -> bookshelves -> books
    lib_bookcases AS (
        SELECT libs_in_sys.*, bookcase.bookcase_id
        FROM libs_in_sys
        JOIN bookcase ON libs_in_sys.library_id = bookcase.library_id),
    lib_book_shelves AS (
        SELECT lib_bookcases.*, bookshelf.bookshelf_id
        FROM lib_bookcases
        JOIN bookshelf ON bookshelf.bookcase_id = lib_bookcases.bookcase_id
    ),
    -- Gets the number of each book owned at each library
    books_in_lib_sys AS (
        SELECT lib_book_shelves.*, book.title AS book_title, book.author, COUNT(book.title) AS num_copies_at_library
        FROM lib_book_shelves
        JOIN book_inventory ON lib_book_shelves.bookshelf_id = book_inventory.bookshelf_id
        JOIN book ON book.isbn = book_inventory.isbn
        -- Get the number of copies of EACH book at EACH library
        GROUP BY lib_book_shelves.library_name, book.title
    )

    SELECT library_name, book_title, author,  num_copies_at_library
        FROM books_in_lib_sys
        ORDER BY book_title ASC;

END $$
-- resets the DELIMETER
DELIMITER ;

-- checking out a book given a book_id and user_id
-- Adds the book to the "checked out book" table,
-- returns the due date
-- Adds book to the user's history
DROP PROCEDURE IF EXISTS checkout_book;
DELIMITER $$
CREATE PROCEDURE checkout_book(
  IN user_id_p INT,
  IN book_title VARCHAR(200),
  IN lib_sys_id_p INT,
  IN lib_id_p INT
) checkout_label:BEGIN
  -- given user_id, book_title, lib_sys_id, & lib_id -> checkout book
  -- RETURN: {rtncode: <code>, due_datetime(if success): <datetime> }
  -- code 1:  Success
  -- code -1: no copies available
  -- code -2: user already has book checked out
  -- code 0: other failure
  -- modify checked_out_books & user_hist tables
  DECLARE checkout_length_days INT;
  DECLARE checkout_datetime DATETIME;
  DECLARE due_datetime DATETIME;
  DECLARE avail_book_id INT;

  -- use transaction bc multiple inserts and should rollback on error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SHOW ERRORS;
    ROLLBACK;
    SELECT 0 as "rtncode", null as "due_date";
  END;
  START TRANSACTION; -- may need to rollback bc multiple inserts

  -- function return -1 if no coopies of the book can be checked out
  SET avail_book_id = is_book_avail(book_title, lib_sys_id_p, lib_id_p, user_id_p);
  IF avail_book_id < 0 THEN
    SELECT avail_book_id as "rtncode", null as "due_date";
    ROLLBACK;
    LEAVE checkout_label;
  END IF;

  SET checkout_length_days = (
    SELECT book_inventory.checkout_length_days FROM book_inventory
    WHERE book_id = avail_book_id
  );

  SET checkout_datetime = NOW();
  SET due_datetime = (SELECT DATE_ADD(checkout_datetime, INTERVAL checkout_length_days DAY));

  -- Adds the book to the check_out_books table
  INSERT INTO checked_out_books (user_id,   book_id,       checkout_date,     due_date)
  VALUES                        (user_id_p, avail_book_id, checkout_datetime, due_datetime);

  -- Adding the checkout into the user_hist table
  INSERT INTO user_hist (loan_id, user_id,   book_borrowed, library_id, date_borrowed)
  VALUES                (DEFAULT, user_id_p, avail_book_id, lib_id_p,   checkout_datetime);

  -- TODO: in checkout return this info: bookcase_local_num & bookshelf_local_num
  SELECT 1 as "rtncode", due_datetime as "due_date";
  COMMIT;
END $$
DELIMITER ;

-- Procedure to place a hold for a book
-- will put a hold on the copy of the book that has been checked out the longest
DROP PROCEDURE IF EXISTS place_hold;
DELIMITER $$
CREATE PROCEDURE place_hold(
  IN user_id_p INT,
  IN title_p VARCHAR(200),
  IN lib_sys_id_p INT,
  IN lib_id_p INT
) place_hold_label:BEGIN
  -- returns {rtncode: <code>}
  -- code = 0: user already placed a hold on that book at that library
  -- code = 1: success
  -- code = 2: user already has the book checked out

  -- get isbn from title
  DECLARE book_isbn VARCHAR(17);

  SET book_isbn = (
    SELECT isbn FROM book WHERE book.title = title_p
  );

  -- make sure user doesnt have a hold on this book already
  IF EXISTS (
    SELECT * FROM holds
    JOIN book ON book.isbn = holds.isbn
    WHERE (lib_sys_id_p = holds.lib_sys_id AND user_id = user_id_p AND holds.isbn = book_isbn)
  ) THEN
    SELECT 0 as rtncode;
    LEAVE place_hold_label;
  END IF;

  -- make sure user doesnt have this book checked out already
  IF EXISTS (
    SELECT * FROM checked_out_books
    JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
    JOIN book ON book.isbn = book_inventory.isbn
    JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
    JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
    JOIN library ON library.library_id = bookcase.library_id
    WHERE (
      lib_sys_id_p = library.library_system AND
      checked_out_books.user_id = user_id_p AND
      book_inventory.isbn = book_isbn
    )
  ) THEN
    SELECT 2 as rtncode;
    LEAVE place_hold_label;
  END IF;

  -- make a hold with that book and user date
  INSERT INTO holds (hold_id, isbn,      user_id,   lib_sys_id,   library_id,  hold_start_date)
  VALUES            (DEFAULT, book_isbn, user_id_p, lib_sys_id_p, lib_id_p,    NOW());

  COMMIT;

  SELECT 1 as rtncode;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS cancel_hold;
DELIMITER $$
CREATE PROCEDURE cancel_hold(IN user_id_in INT, IN hold_id_in INT)
BEGIN
  -- if hold doesnt exist, return 0
  -- if exists and canceled, return 1
  DECLARE rtncode INT;

  IF EXISTS (SELECT * FROM holds WHERE user_id = user_id_in AND hold_id = hold_id_in) THEN
    DELETE FROM holds WHERE user_id = user_id_in AND hold_id = hold_id_in;
    SET rtncode = 1;
  ELSE
    SET rtncode = 0;
  END IF;


  COMMIT;
  SELECT rtncode;

END $$
DELIMITER ;


-- returns a book to the library
-- CALL return_book(4, 1); -- return moby dick from nickrizzo's account
DROP PROCEDURE IF EXISTS return_book;
DELIMITER $$
CREATE PROCEDURE return_book(IN book_id_p INT, IN user_id_p INT)
BEGIN
  DECLARE book_library_id INT;
  DECLARE new_checkout_user_id INT;
  DECLARE checkout_length_days INT;
  DECLARE due_datetime DATE;
  DECLARE isbn_from_p VARCHAR(17);
  -- id of user who's had the longest hold on isbn and will check it out
  DECLARE user_id_checkout_hold INT;

  -- use transaction bc multiple inserts and should rollback on error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SHOW ERRORS;
    ROLLBACK;
    SELECT "Failed to return book, rolling back";
    CALL raise_error;
  END;

  -- Grabs the ISBN of the book being returned
  SELECT isbn FROM book_inventory WHERE (book_inventory.book_id = book_id_p)
    INTO isbn_from_p;

  -- A function to get the library_id for a specific book
  SELECT library_id_from_book(book_id_p) INTO book_library_id;

 -- Adds the return date to the user_Hist
  UPDATE user_hist
  SET date_returned = now()
  WHERE ((user_id_p = user_id) AND
          (book_id_p = book_borrowed));

  -- Delete row from checked_out_Books
  DELETE FROM checked_out_books
  WHERE ((user_id_p = checked_out_books.user_id) AND
          (book_id_p = checked_out_books.book_id));

  -- Checks out the book for the next person on hold, if one exists
  -- Otherwise, the book is return and ready to be checked out by whomever else wants it
  -- We will register the user to whatever copy of the book that has been checked out
  -- for the longest period of time, assuming that it will be the next copy returned
  IF EXISTS (SELECT * FROM holds WHERE (isbn_from_p = isbn)) THEN
    SET new_checkout_user_id = (
      SELECT user_id FROM holds
      WHERE (isbn_from_p = isbn)
      ORDER BY hold_start_date ASC LIMIT 1
    );
    SET checkout_length_days = (SELECT checkout_length_days FROM book_inventory WHERE book_id_p = book_inventory.book_id);
    SET due_datetime = (SELECT DATE_ADD(checkout_datetime, INTERVAL checkout_length_days DAY));

    INSERT INTO checked_out_books (user_id,              book_id,   checkout_date, due_date)
    VALUES                        (new_checkout_user_id, book_id_p, now(),         due_datetime);

    -- Updates user_hist
    SET user_id_checkout_hold = (
      SELECT user_id FROM holds
      WHERE (holds.isbn = isbn_from_p)
      ORDER BY hold_start_date ASC LIMIT 1
    );

    INSERT INTO user_hist (loan_id, user_id, book_borrowed, library_id, date_borrowed, date_returned)
    VALUES (DEFAULT, user_id_checkout_hold, book_id_p, book_library_id, now(), null);

  END IF;

  COMMIT;
END $$
DELIMITER ;


-- Given a user_id, returns all books currently checked out or on hold by user
DELIMITER $$
CREATE PROCEDURE current_hold_and_checked_out(IN user_id_p INT)
BEGIN
   WITH current_holds AS(
    SELECT isbn FROM holds WHERE (user_id_p = user_id)
   ),
   current_checked_out_id AS (
    SELECT book_id FROM checked_out_books WHERE (user_id_p = user_id)
   ),
   current_checked_out_isbn AS (
    SELECT isbn FROM book_inventory
     WHERE (book_id IN (SELECT * FROM current_checked_out_ID))
   )

   -- the table of ISBNs representing the books a specific user
   -- has checked out or has placed a hold on
   SELECT * FROM current_holds
    UNION ALL
   SELECT * FROM current_checked_out_isbn;

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



DROP PROCEDURE IF EXISTS insert_user;
DELIMITER $$
CREATE PROCEDURE insert_user(
-- Inserts a new user into the DB
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
  DECLARE new_lib_card_num INT;
  DECLARE new_lib_card_id INT;
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
  INSERT INTO lib_user (user_id, lib_card_id, first_name, last_name, dob, num_borrowed, is_employee, username, lib_password)
  -- user_id is auto increment, so specify default behavior
  -- hash the password with MD5 & only ever do checks on the hash (no plaintext passwords)
  VALUES(DEFAULT, new_lib_card_id, fname, lname, dob, 0, is_employee, username, MD5(pwd));
  SET new_user_id = LAST_INSERT_ID();

  -- insert into user_register
  INSERT INTO user_register (user_id, library_id) VALUES(new_user_id, in_library_id);
  COMMIT;

END $$
-- resets the DELIMETER
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_employee;
DELIMITER $$
CREATE PROCEDURE insert_employee(
-- Inserts a new employee into the DB
  IN in_hire_date DATE,
  IN in_salary FLOAT,
  IN in_job_role varchar(200),
  -- REQUIRES INSERT USER IS CALLED FIRST AND THE USER'S NEW id IS OBTAINED
  IN in_user_id INT,
  IN in_library_id INT,
  IN in_is_approved BOOL
) BEGIN
  -- in case insert into lib_user fails, start a transaction that can rollback other insertions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
  END;
  START TRANSACTION;

  -- insert into lib_user
  INSERT INTO employee (employee_id, hire_date, salary, job_role, user_id, library_id, is_approved)
  -- employee_id is auto increment, so specify default behavior
  VALUES(DEFAULT, in_hire_date, in_salary, in_job_role, in_user_id, in_library_id, in_is_approved);

  COMMIT;

END $$
-- resets the DELIMETER
DELIMITER ;

-- given a username and library card number, checks to see if
-- that library cards corresponds to that username
DELIMITER $$
CREATE PROCEDURE check_lib_card(IN username_to_test VARCHAR(50), IN card_num INT)
BEGIN
  DECLARE does_user_card_match BOOLEAN;
  SET does_user_card_match = (
    SELECT COUNT(*) > 0
    FROM (
      SELECT
          lib_user.lib_card_id
      FROM lib_user
      JOIN lib_cards on lib_cards.lib_card_id = lib_user.lib_card_id
      WHERE (username = username_to_test and card_num = lib_cards.lib_card_num)
    ) X
  );

  SELECT does_user_card_match;
END $$
DELIMITER ;

-- call check_lib_card("testusername", 0); -- should return true
-- call check_lib_card("testusername", 1000); -- should return false

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
    IN in_isbn VARCHAR(17),
    IN in_author VARCHAR(100),
    IN in_publisher VARCHAR(100),
    IN in_is_audio_book BOOL,
    IN in_num_pages INT,
    IN in_checkout_length_days INT,
    IN in_book_dewey FLOAT,
    IN in_late_fee_per_day FLOAT)

BEGIN

  DECLARE placement_bookshelf_id INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
  END;
  START TRANSACTION;
  -- Using the dewey number of the book, puts it in the right bookshelf + bookshelf
  -- NOTE: in a lot of cases the Dewey Number is an estimate.
  -- Real data domain experts would be needed to provide the exact dewey numbers
  -- Reference: https://www.britannica.com/science/Dewey-Decimal-Classification
  -- Reference (through searching each book): https://catalog.loc.gov/vwebv/ui/en_US/htdocs/help/numbers.html
  SET placement_bookshelf_id = (SELECT get_bookshelf_from_dewey(in_book_dewey, in_lib_id) );

  -- check if book is already in master list, if not then have to add
  IF NOT EXISTS (SELECT 1 FROM book WHERE in_isbn = book.isbn) THEN
    INSERT INTO book (isbn, title, author, publisher, is_audio_book, num_pages, book_dewey)
    VALUES(in_isbn, in_title, in_author, in_publisher, in_is_audio_book, in_num_pages, in_book_dewey);
  END IF;

  INSERT INTO book_inventory (book_id, isbn, bookshelf_id, checkout_length_days, late_fee_per_day)
  VALUES(DEFAULT, in_isbn, placement_bookshelf_id, in_checkout_length_days, in_late_fee_per_day);

  COMMIT;
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
        SELECT COALESCE(MAX(bookcase_local_num) + 1, 1)
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
        SELECT COALESCE(MAX(get_shelfs_in_lib.bookshelf_local_num) + 1, 1)
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
CREATE PROCEDURE get_pending_employees(IN in_user_id INT)
BEGIN
    -- PRECONDITION: the in_user_id is the user_id of an employee
    -- given the user id (of an employee), get ALL pending employees belonging to this employee's library
    -- return their first_name, last_name, job_role, and hire_date

    DECLARE user_lib_id INT;
    -- Only care about employees that are part of the same library
    SELECT library_id INTO user_lib_id
        FROM employee
        WHERE in_user_id = employee.user_id;

    WITH pending_employees AS(
        SELECT hire_date, job_role, user_id, employee_id
        FROM employee
        WHERE is_approved = false AND user_lib_id = employee.library_id
    )

    -- Get all needed information
    SELECT lib_user.first_name,
           lib_user.last_name,
           pending_employees.job_role,
           pending_employees.hire_date,
           pending_employees.employee_id
        FROM pending_employees
        JOIN lib_user
        ON pending_employees.user_id = lib_user.user_id;

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
  SELECT library_id, library_name FROM library ORDER BY library_name ASC;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_library_systems()
BEGIN
  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_sys_id, library_sys_name FROM library_system ORDER BY library_sys_name ASC;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_all_libs_in_system(IN in_lib_sys_id INT)
BEGIN

  -- Needed for validation of register. Can't be function because multiple rows returned
  SELECT library_id, library_name
    FROM library
    WHERE library_system = in_lib_sys_id
    ORDER BY library_name ASC;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_user_hist_from_id(IN in_user_id INT)
BEGIN
    -- Given a user id, return their history of checkout
    -- Return:
    -- book title checked out, date checked out, return date (null or the day), overdue fee ( have to calculate it), library name
    -- preferably in sorted order of checked out date

    WITH get_loan_hist AS (
        SELECT loan_id, book_borrowed AS borrowed_book_id, library_id, date_borrowed, date_returned
        FROM user_hist
        WHERE user_id = in_user_id
    ),
    -- use the borrowed_book_id (FK to inventory) to get its isbn and from there, its title in book
    get_book_name AS (
        SELECT get_loan_hist.*, book.title,
            -- If the book has yet to be returned, assume it will be today when calculating costs
            DATEDIFF(coalesce(get_loan_hist.date_returned, CURDATE()), date_borrowed) AS days_checked_out,
            book_inventory.checkout_length_days AS max_checkout_len_days,
            book_inventory.late_fee_per_day
        FROM get_loan_hist
        LEFT OUTER JOIN book_inventory ON get_loan_hist.borrowed_book_id = book_inventory.book_id
        LEFT OUTER JOIN book ON book_inventory.isbn = book.isbn
    ),
    -- Get the library name from the id
    get_lib_name AS (
        SELECT get_book_name.*, library.library_name
        FROM get_book_name
        LEFT JOIN library ON get_book_name.library_id = library.library_id
    ),
    calc_overdue_costs AS (
        SELECT get_lib_name.library_name, get_lib_name.date_borrowed,
            get_lib_name.date_returned, days_checked_out, get_lib_name.title,
            -- if the days checked out is less than the allowed checkout length, cost is 0
            CASE
                WHEN days_checked_out < max_checkout_len_days THEN 0
                ELSE (days_checked_out - max_checkout_len_days) * late_fee_per_day
            END AS overdue_fee_dollars,
            max_checkout_len_days, late_fee_per_day
        FROM get_lib_name
    )


    SELECT *
    FROM calc_overdue_costs
    ORDER BY calc_overdue_costs.date_borrowed ASC;

END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION is_lib_in_sys(in_lib_id INT, in_lib_sys_id INT)
 RETURNS BOOL
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library name and system, return 1 if the library is in the system
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret
        FROM library
        WHERE
            in_lib_id = library_id
            AND
            in_lib_sys_id = library_system;

    RETURN(ret);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION is_a_lib_sys(in_lib_sys_id INT)
 RETURNS BOOL
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE ret BOOL;
    -- GIVEN a library system name, return 1 if it exists
    -- If a match is found, the count is 1 and ret = 1
    SELECT COUNT(*)>0 INTO ret
        FROM library_system
        WHERE in_lib_sys_id = library_system.library_sys_id;

    RETURN(ret);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_name_from_id(in_lib_id INT)
 RETURNS VARCHAR(100)
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE ret VARCHAR(100) ;
    SELECT library_name INTO ret
        FROM library
        WHERE in_lib_id = library.library_id;

    RETURN(ret);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_sys_name_from_id(in_lib_sys_id INT)
 RETURNS VARCHAR(100)
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE ret VARCHAR(100) ;
    SELECT library_sys_name INTO ret
        FROM library_system
        WHERE in_lib_sys_id = library_system.library_sys_id;

    RETURN(ret);
END $$

DELIMITER $$
CREATE FUNCTION get_lib_sys_id_from_user_id(in_user_id INT)
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE lib_sys_id INT;
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

DROP FUNCTION IF EXISTS get_card_num_by_user_id;
DELIMITER $$
CREATE FUNCTION get_card_num_by_user_id(user_id_p INT)
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
 DECLARE lib_card_num_out INT;

  SELECT lib_cards.lib_card_num
  INTO lib_card_num_out
  FROM lib_user
  JOIN lib_cards ON lib_user.lib_card_id = lib_cards.lib_card_id
  WHERE lib_user.user_id = user_id_p
  LIMIT 1;

  RETURN(lib_card_num_out);
END $$
-- resets the DELIMETER
DELIMITER ;

DROP FUNCTION IF EXISTS get_is_user_employee;
DELIMITER $$
CREATE FUNCTION get_is_user_employee(user_id_p INT)
 RETURNS BOOL
 DETERMINISTIC
 READS SQL DATA
BEGIN
 DECLARE is_user_employee BOOL;

  -- check that an employee exists with a user id corresponding to the given user
  SELECT COUNT(*) > 0
  INTO is_user_employee
  FROM employee
  -- an employee is a VERIFIED employee if they are approved
  WHERE employee.user_id = user_id_p
    AND employee.is_approved = true
  LIMIT 1;

  RETURN(is_user_employee);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_sys_id_from_sys_name(in_lib_sys_name VARCHAR(100))
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE lib_sys_id INT;
    -- GIVEN a user's id, returns the id of the library system
    SELECT library_system INTO lib_sys_id
        FROM library
        WHERE library_id = (
            SELECT library_sys_id
            FROM library_system
            WHERE library_sys_name = in_lib_sys_name
            LIMIT 1
        );

    RETURN(lib_sys_id);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE FUNCTION get_lib_sys_name_from_user_id(in_user_id INT)
 RETURNS VARCHAR(100)
 DETERMINISTIC
 READS SQL DATA
BEGIN
    DECLARE user_lib_id INT;
    DECLARE found_lib_sys_id INT;
    DECLARE lib_sys_name VARCHAR(100);
    -- GIVEN a user's id, returns the id of the library system
    -- SELECT library_system_name INTO lib_sys_name
    SET user_lib_id  = (SELECT library_id FROM user_register WHERE in_user_id = user_id);
    SET found_lib_sys_id = (SELECT library_system FROM library WHERE library_id = user_lib_id);

    SELECT library_sys_name INTO lib_sys_name
        FROM library_system
        WHERE found_lib_sys_id = library_sys_id;

    RETURN(lib_sys_name);
END $$
-- resets the DELIMETER
DELIMITER ;

DROP FUNCTION IF EXISTS get_card_num_by_username;
DELIMITER $$
CREATE FUNCTION get_card_num_by_username(username_p VARCHAR(50))
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
 DECLARE lib_card_num_out INT;

  SELECT lib_cards.lib_card_num
  INTO lib_card_num_out
  FROM lib_user
  JOIN lib_cards ON lib_user.lib_card_id = lib_cards.lib_card_id
  WHERE lib_user.username = username_p
  LIMIT 1;

  RETURN(lib_card_num_out);
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE approve_employee(IN in_employee_id INT)
BEGIN
    -- GIVEN: an employee's employee_id, update their status to be approved
    UPDATE employee
        SET is_approved = true
        WHERE employee_id = in_employee_id;
    commit;
END $$
-- resets the DELIMETER
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE deny_employee_approval(IN in_employee_id INT)
BEGIN
    -- GIVEN: an employee's employee_id, dont approve them by removing them from the employee table
    DELETE FROM employee
        WHERE employee_id = in_employee_id;
    commit;
END $$
-- resets the DELIMETER
DELIMITER ;

DROP FUNCTION IF EXISTS is_employee_pending_by_user_id;
DELIMITER $$
CREATE FUNCTION is_employee_pending_by_user_id(in_user_id INT)
 RETURNS BOOL
 DETERMINISTIC
 READS SQL DATA
BEGIN
 DECLARE is_still_pending BOOL;
  -- return true if the user is still pending as an employee
  -- If the user is not registered as an employee AT ALL - returns false as well

  SELECT COUNT(*)
  INTO is_still_pending
  FROM employee
  WHERE
    -- first make sure the user exists as an employee
    user_id = in_user_id
    AND
    -- must be pending approval
    is_approved = false
  LIMIT 1;

  RETURN(is_still_pending);
END $$
-- resets the DELIMETER

DROP PROCEDURE IF EXISTS get_user_checkouts;
DELIMITER $$
CREATE PROCEDURE get_user_checkouts(IN user_id_p INT)
BEGIN
  -- GIVEN: user_id
  -- RETURNS: user_id, book_title, book_id, author, library_name, checkout_date, due_date

  SELECT
    user_id_p AS "user_id",
    book.title AS book_title,
    checked_out_books.book_id,
    book.author,
    library.library_name,
    checked_out_books.checkout_date,
    checked_out_books.due_date
  FROM checked_out_books
  JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
  JOIN book ON book_inventory.isbn = book.isbn
  JOIN bookshelf ON bookshelf.bookshelf_id = book_inventory.bookshelf_id
  JOIN bookcase ON bookcase.bookcase_id = bookshelf.bookcase_id
  JOIN library ON library.library_id = bookcase.library_id
  WHERE checked_out_books.user_id = user_id_p;

END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_holds;
DELIMITER $$
CREATE PROCEDURE get_user_holds(IN user_id_p INT)
BEGIN
  -- GIVEN: user_id
  -- RETURNS: hold_id, book_title, author, library_name, hold_start_date

  SELECT
    holds.hold_id,
    book.title AS book_title,
    book.author,
    library.library_name,
    holds.hold_start_date
  FROM holds
  JOIN book ON holds.isbn = book.isbn
  JOIN library ON library.library_id = holds.library_id
  WHERE holds.user_id = user_id_p;

END $$
DELIMITER ;

DROP FUNCTION IF EXISTS get_checkout_book_id_from_user_title;
DELIMITER $$
CREATE FUNCTION get_checkout_book_id_from_user_title(user_id_in INT, book_title_in VARCHAR(200))
 RETURNS INT
 DETERMINISTIC
 READS SQL DATA
BEGIN
 DECLARE book_id_out INT;

  SELECT checked_out_books.book_id
  INTO book_id_out
  FROM checked_out_books
  JOIN book_inventory ON book_inventory.book_id = checked_out_books.book_id
  JOIN book ON book.isbn = book_inventory.isbn
  WHERE checked_out_books.user_id = user_id_in AND book.title = book_title_in
  LIMIT 1;

  RETURN(book_id_out);
END $$
DELIMITER ;

-- ######## CALL SCRIPTS TO ADD DATA TO DATABASE
-- Taken from the add_test_data/ scripts
-- ##### ADD Library Systems ####
-- many systems come from here https://mblc.state.ma.us/programs-and-support/library-networks/index.php
INSERT INTO library_system (library_sys_name) VALUES
    ("Metro Boston Library Network"),
    ("Old Colony Library Network"),
    -- https://www.minlib.net/our-libraries
    ("Minuteman Library Network");

-- ##### ADD Library's ####
-- Add a few libraries. Have 5 libraries spread across 2 library systems.

-- Metro Boston Library locations come from here:
-- https://bpl.bibliocommons.com/locations/
-- Simplifying hours of operation to weekdays
CALL add_library("Metro Boston Library Network", "Charlestown",
        "179 Main St Charlestown, MA 02129", '10:00', '18:00', 5);
CALL add_library("Metro Boston Library Network", "Central Library in Copley Square",
        "700 Boylston Street Boston, MA 02116", '10:00', '20:00', 5);
CALL add_library("Metro Boston Library Network", "Jamaica Plain",
        "30 South Street Jamaica Plain, MA 02130", '10:00', '18:00', 5);
-- Reference: https://catalog.ocln.org/client/en_US/ocln/?rm=LIBRARY+LOCATI1%7C%7C%7C1%7C%7C%7C3%7C%7C%7Ctrue
CALL add_library("Old Colony Library Network", "Plymouth Public Library",
        "132 South Street Plymouth, MA 02360", '10:00', '21:00', 8);
CALL add_library("Old Colony Library Network", "Kingston Public Library",
        "6 Green Street Kingston, MA 02364", '10:00', '17:00', 4);

-- https://www.minlib.net/our-libraries
CALL add_library("Minuteman Library Network", "Cambridge Public Library",
        "449 Broadway Cambridge, MA 02138", '10:00', '21:00', 4);


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

CALL add_bookcase(6, 0, 499);
CALL add_bookcase(6, 500, 999);
CALL add_bookshelf(6, 0, 99);
CALL add_bookshelf(6, 100, 399);
CALL add_bookshelf(6, 400, 499);
CALL add_bookshelf(6, 500, 639);
CALL add_bookshelf(6, 640, 999);

-- ##### ADD ourselves as Employees ####
CALL insert_user(
  "nick", "rizzo",
  1, -- library_id = 1 (Charlestown - needed to test checkout_book)
  CURDATE(), true, "nickrizzo", "pwd"
);
-- Can do this because this is being done manually in order
CALL insert_employee(CURDATE(), 60000,
    "Manages the Charlestown library. Can add new books to the catalog.",
    -- NOTE: both of these ONLY work because it is being done manually.
    -- Registration of actual emplyees via the application will handle this
    -- First is user id - 1 because nick rizzo is the first user
    -- 2nd is library id - 1 because it can be seen above
    1, 1, true);

CALL insert_user(
  "Matt", "Rizzo",
  4, -- library_id = 4 (Plymouth Public Library - another system)
  CURDATE(), true, "mattrizzo", "pwd"
);

CALL insert_employee(CURDATE(), 55000,
    "Manages the Plymouth Public library. Can add new books to the catalog.",
    -- NOTE: both of these ONLY work because it is being done manually.
    -- Registration of actual emplyees via the application will handle this
    -- First is user id - 2nd user to be added
    -- 2nd is library id
    2, 4, true);

CALL insert_user(
  "Domenic", "Privitera",
  6, -- library_id = 6 (Cambridge Public Library - system 3)
  CURDATE(), true, "dompriv", "pwd"
);

CALL insert_employee(CURDATE(), 70000,
    "Manages the Cambridge Public library. Can add new books to the catalog.",
    -- NOTE: both of these ONLY work because it is being done manually.
    -- Registration of actual emplyees via the application will handle this
    -- First is user id - 3rd user to be added
    -- 2nd is library id
    3, 6, true);

CALL insert_user(
  "Central", "Emp",
  2,
  CURDATE(), true, "central_employee", "central_pwd"
);
-- Can do this because this is being done manually in order
CALL insert_employee(CURDATE(), 65300,
    "Manages the Central Library in Copley Square. Can add new books to the catalog.",
    4, 2, true);

CALL insert_user(
  "Jamaica", "Emp",
  3,
  CURDATE(), true, "jamaica_employee", "jamaica_pwd"
);
-- Can do this because this is being done manually in order
CALL insert_employee(CURDATE(), 59870,
    "Manages the Jamaica Plain Library. Can add new books to the catalog.",
    5, 3, true);



CALL insert_user(
  "Kingston", "Emp",
  5,
  CURDATE(), true, "kingston_employee", "kingston_pwd"
);
-- Can do this because this is being done manually in order
CALL insert_employee(CURDATE(), 53240,
    "Manages the Kingston Plain Library. Can add new books to the catalog.",
    6, 5, true);



CALL insert_user(
  "fname", "lname",
  1, -- library_id = 1 (Charlestown - same as nickrizzo needed to test hold_book)
  CURDATE(), true, "holdacct", "pwd"
);

-- ##### ADD some BOOKS ####
CALL add_new_book("Database Systems - A Practical Approach to Design, Implementation, and Management",
    -- This only works bc custom data, change eventually
    1, "978-0-13-294326-0", "Thomas Connolly and Carolyn Begg", "Pearson",
    false, 1442, 2, 005.74, 10);

-- have Moby Dick be in 2 libraries in the same system (make the lib id be 1 and 2)
CALL add_new_book("Moby Dick", 1, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 10, 812.54, .3);
-- Have 2 copies of the same book in 1 library
CALL add_new_book("Moby Dick", 1, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 21, 812.54, .3);
CALL add_new_book("Moby Dick", 2, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 9, 812.54, .3);

-- Also put Moby Dick in another system to test the search results
CALL add_new_book("Moby Dick", 6, '9780425120231', 'Herman Melville', 'Berkley Pub Group',
    false, 704, 14, 812.54, .3);

-- Add at least 1 book to every library
CALL add_new_book("The Institute", 2, 9781432870126, "Stephen King", "Scribner",
    false, 576, 14, 813.54, .5);
CALL add_new_book("How to do nothing : resisting the attention economy", 3, 9781612197500,
    "Jenny Odell", "Melville House", false, 256, 20, 303.48, .05);
CALL add_new_book("Majesty", 4, 9781984830227 , "Katharine McGee", "Random House",
    false, 448 , 7, 813.6, .20);
CALL add_new_book("Pride and Prejudice", 5, 9781435171589, "Jane Austen",
    "Barnes & Noble Signature Classics Series", false, 384, 16, 823.7, .12);
CALL add_new_book("Little Red Riding Hood", 5, 9780316013550, "	Brothers Grimm",
    "Little, Brown and Company", false, 34, 8, 398.2, .10);
CALL add_new_book("A Modern Utopia", 6, 9780486808352 , "H. G. Wells",
    "Chapman and Hall", false, 393, 14, 321.07, .1);

-- Put at least 1 audio book in every library
CALL add_new_book("American Republics: A Continental History of the United States, 1783-1850",
    1, 9781324005797 , "Alan Taylor",
    "W. W. Norton & Company ", true, 544,
    12, 973.3, .15);
CALL add_new_book("China Room", 2,  9780593298145 , "Sunjeev Sahota",
    "Penguin Audio", true, 243, 7, 823.92, .2);
CALL add_new_book("The Death of the Heart", 3,  9781705286647, "Elizabeth Bowen",
    "Knopf", true, 445, 15, 823.912, .05);
CALL add_new_book("Empire of Pain: The Secret History of the Sackler Dynasty", 4,
    0385545681, "Patrick Radden Keefe",
    "Random House Audio", true, 535 , 14, 338.7, .03);
CALL add_new_book("Exit", 5, 9781662065965, "Belinda Bauer",
    "Dreamscape Media, LLC", true, 336, 11, 823.92, .2);
CALL add_new_book("The Man Who Died Twice: A Thursday Murder Club Mystery", 6,
    9780841993583, "Richard Osman", "Penguin Audio", true, 365, 14, 823.92, .06);

-- Just add some random books
CALL add_new_book("Alice's Adventures in Wonderland", 3,
    9780977716173, "Lewis Carroll", "Macmillan", false, 176, 14, 823.8, .03);
CALL add_new_book("American Gods", 3,
    9783962190019, "Neil Gaiman", "William Morrow, Headline", false,
    465, 14, 813.54, .09);
CALL add_new_book("Death of a Salesman", 4,
    9780140481341, "Arthur Miller", "Penguin Plays", false,
    139, 21, 812.52, .06);

-- have test user checkout one copy of Moby Dick (2 available)
-- user_id = 1, book_title = moby dick, lib_sys_id = 1(Metro Boston Library Network), lib_id = 1 (match insert above = Charlestown)
-- test search with user: nickrizzo -> moby dick
-- in web app, try checking out second copy of "moby dick" at this library
CALL checkout_book(1, "Moby Dick", 1, 1); -- will work twice (but then no more copies available)
CALL checkout_book(1, "Moby Dick", 1, 2); -- get last copy of moby dick in system (but diff lib)
CALL checkout_book(7, "China Room", 1, 2); -- get last copy of "China Room" on holdacct so nickrizzo can place hold
CALL place_hold(1, "China Room", 1, 2); -- have nickrizzo place hold on China Room to see in profile
