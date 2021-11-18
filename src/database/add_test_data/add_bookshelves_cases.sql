USE libsystem;
-- Script to add bookshelves and book cases for 3 libraries

-- STEP 1 - run the add_lib_sys.sql script
-- STEP 2 - add bookcases for large ranges (Dewey has 10 groups)
-- NOTE: these id's are hard coded for now, due to parallel work / branch git flow.
--      The real system backend will use a user id and procedures to get the true library id.

-- Make sure each library has at least 1 case. All the cases/shelves combined should cover all dewey ranges (000-999)

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

SELECT bookcase.bookcase_id, bookcase.dewey_min, bookcase.dewey_max FROM (
        -- Get the bookcase(s) this shelf could belong to in the library
        SELECT bookcase_id, bookcase.dewey_min, bookcase.dewey_max FROM bookcase WHERE library_id = 1
        ) getBookcasesID
        -- Get all bookcases in the library and their shelve
        RIGHT JOIN bookcase
        ON getBookcasesID.bookcase_id = bookcase.bookcase_id
        -- Find the bookcases in the library that fit the dewey ranges
        WHERE 0 >= getBookcasesID.dewey_min AND 500 <= getBookcasesID.dewey_max
        ORDER BY bookcase.bookcase_id DESC
        LIMIT 1;

