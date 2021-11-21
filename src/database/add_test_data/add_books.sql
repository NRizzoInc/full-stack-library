-- Used for adding books to test with.
-- Because the procedure doesnt exist yet, doesn't add it to the bookshelf or bookcase tables yet

-- Step 1 - run add_lib_sys.sql
-- Step 2 - run add_bookshelves_cases.sql
-- Step 3 - run this script

-- GOALS WHEN DONE:
-- have 3 library systems
-- Have 5 libraries spread across 2 library systems
-- Have at least 1 book case (with at least 1 shelf each) in every library
-- Have 20 books. Spread them across 2 library systems.
--      Have them in 3 libraries total. 2 of the libraries should be in the same system.
--      Some of the books (in the same system) should have the same name.

-- order:
-- in_title, in_lib_id, in_isbn, in_author, in_publisher, in_is_audio_book
-- in_num_pages, in_checkout_length_days, in_book_dewey, in_late_fee_per_day
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
    