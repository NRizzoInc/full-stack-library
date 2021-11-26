from flask_table import Table, Col
from flask_table.columns import ButtonCol, DatetimeCol

from typing import Optional, Dict, List

class ProfileCheckoutTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    centered = {"column_html_attrs": {"class": "has-text-centered"}}
    no_items = "No Checked Out Items"
    book_title = Col('Book Title', **centered)
    author = Col('Author', **centered)
    library_name = Col('Library Name', **centered)
    checkout_date = DatetimeCol('Checkout Date', **centered)
    due_date = DatetimeCol('Due Date', **centered)
    rtn_book = ButtonCol(
        name='Return Book',
        endpoint="returns",
        url_kwargs=dict(
            book_title = "book_title",
            # user_id = "user_id",
            # book_id = "book_id",
        ),
        # change class of cells
        button_attrs={"class": "button is-link"},
        **centered
    )
    border = True

class ProfileCheckoutTbCell(object):
    def __init__(self, user_id, book_title, book_id, author, library_name, checkout_date, due_date):

        # self.user_id = user_id
        # self.book_id = book_id
        self.book_title = book_title
        self.author = author
        self.library_name = library_name
        self.checkout_date = checkout_date
        self.due_date = due_date

        # contains info for dynamically generated links for buttons
        self.rtn_book = {
            "book_title": self.book_title,
            # "user_id": self.user_id,
            # "book_id": self.book_id,
        }

def create_profile_checkout_cells(raw_res_list : List[Dict]) -> List[ProfileCheckoutTbCell]:
    """Given: user_id, book_title, book_id, author, library_name, checkout_date, due_date
    Returns: list of ProfileCheckoutTbCell objects for ProfileCheckoutTable"""
    if raw_res_list is None: return []

    search_res = []
    for result in raw_res_list:
        search_res.append(ProfileCheckoutTbCell(**result))
    return search_res
