USE libSystem;

DROP PROCEDURE IF EXISTS checkout_book_on_day;
DELIMITER $$
CREATE PROCEDURE checkout_book_on_day(
  IN user_id_p INT,
  IN book_title VARCHAR(200),
  IN lib_sys_id_p INT,
  IN lib_id_p INT,
  IN day_of_checkout DATETIME
) checkout_label:BEGIN
  -- NOTE: THIS IS A TESTING ONLY PROCEDURE. IT SHOULD NOT BE INCLUDED IN THE MAIN SQL AND DUMP
  -- PURPOSE: to ensure the calculation of fees for overdue books is correct

  -- given user_id, book_title, lib_sys_id, & lib_id, day to checkout -> checkout book
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

  -- function return -1 if no coopies of the book can be checked out
  SET avail_book_id = is_book_avail(book_title, lib_sys_id_p, lib_id_p, user_id_p);
  IF avail_book_id < 0 THEN
    SELECT avail_book_id as "rtncode", null as "due_date";
    LEAVE checkout_label;
  END IF;

  SET checkout_length_days = (
    SELECT book_inventory.checkout_length_days FROM book_inventory
    WHERE book_id = avail_book_id
  );

  SET checkout_datetime = day_of_checkout;

  SET due_datetime = (SELECT DATE_ADD(checkout_datetime, INTERVAL checkout_length_days DAY));

  -- Adds the book to the check_out_books table
  START TRANSACTION; -- may need to rollback bc multiple inserts
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


CALL checkout_book_on_day(1,
    "Database Systems - A Practical Approach to Design, Implementation, and Management",
    1, 1,
    '2021-11-23 10:10:10');