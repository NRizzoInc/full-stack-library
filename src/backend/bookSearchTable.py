from flask_table import Table, Col

class BookSearchTable(Table):
    book_title = Col('Book Title')
    num_avail = Col('Number of Copies Available')
    border = True

class BookSearchCell(object):
    def __init__(self, book_title, num_avail):
        self.book_title = book_title
        self.num_avail = num_avail