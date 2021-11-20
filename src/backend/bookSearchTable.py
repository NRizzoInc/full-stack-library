from flask_table import Table, Col
from flask_table.columns import LinkCol, ButtonCol

from typing import Optional, Dict, List

class BookSearchTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    lib_name = Col('Library Name')
    total_num_at_lib = Col('Total Number of Copies at Library')
    num_avail = Col('Number of Copies Available')
    num_checked_out = Col('Number of Copies Checked Out')
    num_holds = Col('Number of Holds')
    case_num = Col('Bookcase # in Library')
    shelf_num = Col('Bookshelf # in Library')
    checkout = ButtonCol(
        name='Perform Checkout/Place Hold',
        endpoint="checkout",
        url_kwargs=dict(
            book_title="book_title",
            # book_id="book_id",
            is_hold="is_hold"
        ),
        # change class of cells
        button_attrs= {"class": "button is-link"}
    )
    border = True

class BookSearchCell(object):
    def __init__(self,
                lib_name, total_num_at_lib, num_avail, num_checked_out,
                num_holds, case_num, shelf_num,
                # Used for checkout url
                book_title):

        self.lib_name = lib_name
        self.total_num_at_lib = total_num_at_lib
        self.num_checked_out = num_checked_out
        self.num_holds = num_holds
        self.num_avail = num_avail
        self.case_num = case_num
        self.shelf_num = shelf_num

        # Used for checkout url
        # self.book_id = book_id
        self.book_title = book_title
        self.is_hold = num_avail == 0
        self.checkout = {
            "book_title": book_title,
            # "book_id": book_id,
            # If there are no book left, a hold should be placed
            "is_hold": "hold" if self.is_hold else "checkout"
        }

def create_search_cells(raw_res_list : List[Dict], book_title : str) -> List[BookSearchCell]:
    """Given the raw results of a serach, generates a list of BookSearchCell objects.
    Can be used to create a BookSearchTable object"""
    search_res = []
    if raw_res_list is not None:
        # Keep adding to the search results list with cell objects
        # Will ad-hoc generate a table on the webpage with all the results
        for result in raw_res_list:
            search_res.append(
                BookSearchCell(result['library_name'], result['num_copies_at_library'],
                    result['num_copies_in_stock'], result['num_checked_out'],
                    result['number_holds'], result['bookcase_local_num'],
                    result['bookshelf_local_num'], book_title)
            )
    return search_res
