from flask_table import Table, Col
from flask_table.columns import LinkCol

class BookSearchTable(Table):
    book_title = Col('Book Title')
    num_avail = Col('Number of Copies Available')
    checkout = LinkCol(
        name='Perform Checkout',
        endpoint="checkout",
        url_kwargs=dict(book_id="book_id", book_title="book_title")
    )
    border = True

class BookSearchCell(object):
    def __init__(self, book_id, book_title, num_avail):
        self.book_id = book_id
        self.book_title = book_title
        self.num_avail = num_avail
        self.checkout = {
            "book_id": book_id,
            "book_title": book_title
        }
