from flask_table import Table, Col
from flask_table.columns import LinkCol

class BookSearchTable(Table):
    lib_name = Col('Library Name')
    total_num_at_lib = Col('Total Number of Copies at Library')
    num_avail = Col('Number of Copies Available')
    num_checked_out = Col('Number of Copies Checked Out')
    num_holds = Col('Number of Holds')
    case_num = Col('Bookcase # in Library')
    shelf_num = Col('Bookshelf # in Library')
    checkout = LinkCol(
        name='Perform Checkout/Place Hold',
        endpoint="checkout",
        url_kwargs=dict(book_id="book_id",
                        book_title="book_title",
                        is_place_hold="is_place_hold")
    )
    border = True

class BookSearchCell(object):
    def __init__(self,
                lib_name, total_num_at_lib, num_avail, num_checked_out,
                num_holds, case_num, shelf_num,
                # Used for checkout url
                book_id, book_title):

        self.lib_name = lib_name
        self.total_num_at_lib = total_num_at_lib
        self.num_checked_out = num_checked_out
        self.num_holds = num_holds
        self.num_avail = num_avail
        self.case_num = case_num
        self.shelf_num = shelf_num

        # Used for checkout url
        self.book_id = book_id
        self.book_title = book_title
        self.is_place_hold = num_avail == 0
        self.checkout = {
            "book_id": book_id,
            "book_title": book_title,
            # If there are no book left, a hold should be placed
            "is_place_hold": self.is_place_hold
        }
