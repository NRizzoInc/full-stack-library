from flask_table import Table, Col
from flask_table.columns import LinkCol, ButtonCol

from typing import Optional, Dict, List

class UserHistoryTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    lib_name = Col('Library Name')
    book_title = Col("Title of Book Borrowed")
    date_borrowed = Col("Date of Checkout")
    date_returned = Col("Date of Return - N/A if still checked out")
    days_checked_out = Col("Number of Days Checked Out")
    max_checkout_len_days = Col("Maximum Checkout Length (Days)")
    overdue_fees = Col("Fees ($) - N/A if there are none")

    border = True
    no_items = f"You currently have no user history. You will start one once you checkout a book."

class UserHistoryCell(object):
    def __init__(self,
        lib_name,
        book_title,
        date_borrowed,
        date_returned,
        days_checked_out,
        overdue_fees,
        max_checkout_len_days
    ):

        self.lib_name = lib_name
        self.book_title = book_title
        self.date_borrowed = date_borrowed
        self.date_returned = date_returned
        self.days_checked_out = days_checked_out
        self.max_checkout_len_days = max_checkout_len_days
        self.overdue_fees = overdue_fees

def create_user_history_cells(raw_res_list : List[Dict]) -> List[UserHistoryCell]:
    """Given the raw results of a serach, generates a list of UserHistoryCell objects.
    Can be used to create a UserHistoryTable object"""
    search_res = []
    if raw_res_list is not None:
        # Keep adding to the search results list with cell objects
        # Will ad-hoc generate a table on the webpage with all the results
        for result in raw_res_list:
            overdue_fee = "N/A"
            # If the book is overdue, display the fee and the cost per day
            if result['overdue_fee_dollars'] != 0:
                overdue_fee = '{} (${} per day)'.format(result['overdue_fee_dollars'], result['late_fee_per_day'])
            return_date = "N/A" if result['date_returned'] is None else result['date_returned']
            search_res.append(
                UserHistoryCell(
                    result['library_name'], result['title'],
                    result['date_borrowed'], return_date,
                    result['days_checked_out'], overdue_fee,
                    result['max_checkout_len_days']
                )
            )
    return search_res
