from flask_table import Table, Col
from flask_table.columns import ButtonCol, DatetimeCol

from typing import Optional, Dict, List

class ProfileHoldsTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    centered = {"column_html_attrs": {"class": "has-text-centered"}}
    no_items = "No Books on Hold"
    border = True

    book_title = Col('Book Title', **centered)
    author = Col('Author', **centered)
    library_name = Col('Library Name', **centered)
    hold_start_date = DatetimeCol('Hold Start Date', **centered)
    cancel_holds = ButtonCol(
        name='Cancel Hold ',
        endpoint="cancel_hold",
        url_kwargs=dict(
            hold_id = "hold_id",
        ),
        button_attrs={"class": "button is-danger"},
        **centered
    )

class ProfileHoldsTbCell(object):
    def __init__(self, hold_id, book_title, author, library_name, hold_start_date):

        self.hold_id = hold_id
        self.book_title = book_title
        self.author = author
        self.library_name = library_name
        self.hold_start_date = hold_start_date

        # contains info for dynamically generated links for buttons
        self.cancel_holds = {
            "hold_id": self.hold_id,
        }

def create_profile_holds_cells(raw_res_list : List[Dict]) -> List[ProfileHoldsTbCell]:
    """Given: hold_id, book_title, author, library_name, hold_start_date
    Returns: list of ProfileHoldsTbCell objects for ProfileHoldsTable"""
    if raw_res_list is None: return []

    search_res = []
    for result in raw_res_list:
        search_res.append(ProfileHoldsTbCell(**result))
    return search_res
