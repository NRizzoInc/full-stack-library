from flask_table import Table, Col
from flask_table.columns import DateCol, LinkCol, ButtonCol

from typing import Optional, Dict, List

class PendingEmployeeTable(Table):
    classes = ["table", "is-bordered", "is-striped", "is-hoverable", "is-fullwidth"]
    first_name = Col('First name')
    last_name = Col('Last Name')
    job_role = Col('Job Description')
    hire_date = DateCol('Hire Date')
    approve = ButtonCol(
        name='Approve Employee',
        endpoint="change_pending_employee_status",
        url_kwargs=dict(
            # method of getting book ('approve' or 'deny')
            action="approve",
            employee_id="employee_id"
        ),
        # change class of cells
        button_attrs= {"class": "button is-link"}
    )
    deny = ButtonCol(
        name='Deny Employee Verification',
        endpoint="change_pending_employee_status",
        url_kwargs=dict(
            # method of getting book ('approve' or 'deny')
            action="deny",
            employee_id="employee_id"
        ),
        # change class of cells
        button_attrs= {"class": "button is-link"}
    )
    border = True

class PendingEmployeeCell(object):
    def __init__(self,
        first_name,
        last_name,
        job_role,
        hire_date,
        # Used for url
        employee_id
    ):

        self.first_name = first_name
        self.last_name = last_name
        self.job_role = job_role
        self.hire_date = hire_date

        # Used for url formation
        self.employee_id = employee_id
        # Which one of these is used gets picked by the botton
        self.approve = "approve"
        self.deny = "deny"

def create_pending_employee_cells(raw_res_list : List[Dict]) -> List[PendingEmployeeCell]:
    """Given the raw results of finding pending employees, generates a list of PendingEmployeeCell objects.
    Can be used to create a PendingEmployeeTable object"""
    res = []
    if raw_res_list is not None:
        # Keep adding to the search results list with cell objects
        # Will ad-hoc generate a table on the webpage with all the results
        for result in raw_res_list:
            res.append(
                PendingEmployeeCell(
                    result['first_name'], result['last_name'],
                    result['job_role'], result['hire_date'],
                    result['employee_id'],
                )
            )
    return res
