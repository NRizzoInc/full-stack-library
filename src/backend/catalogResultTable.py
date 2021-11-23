from flask_table import Table, Col
from flask_table.columns import LinkCol

from typing import Optional, Dict, List

class CatalogResultTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    book_title = Col("Book Name")
    author = Col("Author")
    lib_name = Col('Library Name')
    total_num_at_lib = Col('Total Number of Copies at Library')
    border = True
    no_items = "This Library System has no books in its catalog"

class CatalogResultCell(object):
    def __init__(self,
                book_title, lib_name, total_num_at_lib, author):
        self.book_title = book_title
        self.lib_name = lib_name
        self.author = author
        self.total_num_at_lib = total_num_at_lib

def create_catalog_cells(raw_catalog_list : List[Dict]) -> List[CatalogResultCell]:
    """Given the raw results of a serach, generates a list of CatalogResultCell objects.
    Can be used to create a CatalogResultTable object"""
    catalog_res = []
    if raw_catalog_list is not None:
        # Keep adding to the search results list with cell objects
        # Will ad-hoc generate a table on the webpage with all the results
        for result in raw_catalog_list:
            catalog_res.append(
                CatalogResultCell(
                    book_title = result['book_title'],
                    author = result['author'],
                    lib_name = result['library_name'],
                    total_num_at_lib = result['num_copies_at_library'])
            )
    return catalog_res