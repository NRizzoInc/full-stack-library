# Database Readme
This folder holds sql code for the application (like creating procedures)

## For Dom - procedures to make
* take book title, give back copies available, number of holds, library it is at
* given username, get their password - need this to check if login is valid
* given username, return true (1) if username is not currently used, false (0) if not used
* given username - get user_id
* for checkout: take a book id and user_id
  * add the book the checkout table
  * reduce the number of available copies of the book (update the book table)
  * calculate the due date (and return it)
* for return: take book_id and user_id
  * increase number of available copies of the book (update book table)
  * add a return date to user history for this book
  * is there more??
* others?