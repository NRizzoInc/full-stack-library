-- Get the book (regardless of library)
   WITH matching_books AS (
     SELECT author, checkout_length_days
      FROM book
      -- this is book_name
      WHERE title = "Bob the builder")
    SELECT matching_books.author, matching_books.checkout_length_days
        FROM matching_books
        LEFT OUTER JOIN bookshelf
        ON matching_books.bookshelf_id = bookshelf.bookshelf_id;


-- current PROCEDURE
DELIMITER $$
CREATE PROCEDURE search_for_book(IN book_name VARCHAR(100))
BEGIN
  -- Note: This searches for the book that matches the name,
  --        and belongs to the user's library System
  -- Return the following Fields:
  -- Author, Library Available at, Number of Copies, Number of Holds, Length of Checkout (Days)

  -- Get the book (regardless of library)
   WITH matching_books AS (
     SELECT author, checkout_length_days
      FROM book
      WHERE title = book_name)
    SELECT matching_books.author, matching_books.checkout_length_days
        FROM matching_books
        LEFT OUTER JOIN bookshelf
        ON matching_books.bookshelf_id = bookshelf.bookshelf_id;


  -- TODO: include the bookcase and bookshelf
END $$
-- resets the DELIMETER
DELIMITER ;