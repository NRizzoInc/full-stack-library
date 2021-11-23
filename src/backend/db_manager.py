#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import argparse # cli paths
import datetime
from typing import Optional, Dict, List

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import pymysql

class DB_Manager():
    def __init__(self, user:str, pwd:str, db:str):
        """
            \n@param: user  - The username to connect to database with
            \n@param: pwd   - The password to connect to database with
            \n@param: db    - The name of the database to connect with
        """
        try:
            self.conn = pymysql.connect(
                host="localhost",
                user=user,
                password=pwd,
                db=db,
                charset="utf8mb4",
                cursorclass=pymysql.cursors.DictCursor
            )
            self.cursor = self.conn.cursor()
        except Exception as err:
            raise SystemExit(f"Invalid Database Login: {err}")

    def cleanup(self):
        self.cursor.close()
        self.conn.close()

    def doesUsernameExist(self, username: str) -> bool():
        self.cursor.execute("call does_username_exist(%s)", username)
        # procedure MUST return something (true/false) so [0] will always work
        try:
            exists_res = list(self.cursor.fetchall()[0].values())[0]
            exists_bool = exists_res == 1 or exists_res == True or exists_res == "True"
            return exists_bool
        except:
            # in worst case, say username is taken
            return True

    def getPwdFromUsername(self, username: str) -> str():
        """(use checkPwdMatches) Returns the hashed password for a given username. Empty string if username does not exist"""

        self.cursor.execute("call get_user_pass(%s)", username)
        try:
            pwds = self.cursor.fetchall()
            # use '.values()' to make python agnostic to the name of returned col in procedure
            return pwds[0].values()[0] if len(pwds) > 0 else None
        except:
            return None

    def checkPwdMatches(self, username: str, pwd: str) -> bool():
        """Returns true if the hash of the passed password matches the stored hashed password"""
        try:
            self.cursor.execute("call check_password(%s, %s)", (username, pwd))
            check_pwd_results = self.cursor.fetchall()
            valid_login_str = (list(check_pwd_results[0].values()))[0]
            valid_login = True if valid_login_str == True or valid_login_str == "True" else False
            return valid_login
        except Exception as err:
            # worst case say login failed
            print(f"Password check failed: {err}")
            return False

    def getUserIdFromUsername(self, username: str) -> int():
        """Returns the id for a given username. -1 if username does not exist"""

        try:
            self.cursor.execute("select get_user_id(%s)", username)
            user_ids = list(self.cursor.fetchone().values())[0]
            # use '.values()' to make python agnostic to the name of returned col in procedure
            # return user_ids[0].values()[0] if len(user_ids) > 0 else -1
            return user_ids if user_ids is not None else -1
        except:
            return -1

    def checkLibCardMatchesUsername(self, username: str, cardnum: int) -> bool:
        """Returns True if the username and cardnum are valid for a user, False if dne, error, or invalid"""
        try:
            self.cursor.execute("call check_lib_card(%s, %s)", (username, cardnum))
            check_card_res = self.cursor.fetchall()
            valid_match_str = (list(check_card_res[0].values()))[0]
            valid_match = True if \
                valid_match_str == True or \
                valid_match_str == "True" or \
                valid_match_str == 1 else False
            return valid_match
        except:
            return False

    def addUser(self,
        fname: str,
        lname: str,
        library_id: str,
        dob: str,
        is_employee: bool,
        username: str,
        pwd: str
    ) -> int():
        """Adds a user to the database. Return 1 if successful, -1 if username taken, else 0"""
        try:
            if(self.doesUsernameExist(username)):
                print("Username already exists")
                return -1
            res = self.cursor.execute("call insert_user(%s, %s, %s, %s, %s, %s, %s)",
                                (fname, lname, library_id, dob, is_employee, username, pwd))
            return 1
        except Exception as error:
            print("Error adding user: " + str(error))
            return 0

    def addEmployee(self,
        hire_date: str,
        salary: float,
        job_role: str,
        user_id: int,
        library_id: int,
        # This should almost ALWAYS be false, but include just in case
        # approval is usually done after registration in employee_actions
        is_approved : bool
        ) -> int:
        """Adds an employee. Note: MUST be called AFTER a successful `addUser`.
        \n:return - 1 on success, -1 on failure"""
        try:
            res = self.cursor.execute("call insert_employee(%s, %s, %s, %s, %s, %s)",
                                    (hire_date, salary, job_role, user_id, library_id, is_approved))
            return 1
        except Exception as error:
            print("Error adding employee: " + str(error))
            return -1


    def updatePwd(self, username: str, pwd: str) -> bool:
        """Updates a user's password (with 'username'). NOTE: Only call after validation. Return True = success"""
        try:
            num_rows = self.cursor.execute("call update_pwd(%s, %s)", (username, pwd))
            # only one row should have been affected
            if num_rows == 1: self.conn.commit()
            return num_rows == 1
        except:
            return False

    def removeUser(self, userToken):
        """
            \n@Brief: Remove a user
            \n@Param: userToken - The user's unique token
        """
        # TODO: implement removing a user (delete row from table)
        pass

    def get_lib_id_from_user_id(self, user_id: int) -> Optional[int]:
        try:
            self.cursor.execute("select get_users_lib_id(%s)", user_id)
            lib_id = list(self.cursor.fetchone().values())[0]
            return lib_id if lib_id is not None else None
        except:
            return False

    def get_lib_id_from_name(self, lib_name: str, lib_system_name: str) -> Optional[int]:
        try:
            self.cursor.execute("select get_lib_id_from_name(%s, %s)", (lib_name, lib_system_name))
            # functions return table where key = entire statement & value = return
            lib_id = list(self.cursor.fetchone().values())[0]
            return lib_id if lib_id is not None else None
        except:
            return False

    def get_all_libraries(self) -> Dict[int, str]:
        """Returns a dictionary of {lib_id: lib_name}"""
        try:
            self.cursor.execute("call get_all_libraries()")
            library_list = self.cursor.fetchall()
            # Flatten 3D list of dict (of rows) into 1 dict
            library_dict = {}
            for row in library_list:
                # each row is {id: id, sys_name: name}
                id_name_list = list(row.values())
                library_dict[id_name_list[0]] = id_name_list[1]
            return library_dict
        except:
            return dict()

    def get_all_library_systems(self) -> Dict[int, str]:
        """Returns a dictionary of {lib_sys_id: lib_sys_name}"""
        try:
            self.cursor.execute("call get_all_library_systems()")
            library_sys_list = self.cursor.fetchall()
            # Flatten 3D list of dict (of rows) into 1 dict
            library_sys_dict = {}
            for row in library_sys_list:
                # each row is {id: id, sys_name: name}
                id_name_list = list(row.values())
                library_sys_dict[id_name_list[0]] = id_name_list[1]
            return library_sys_dict
        except:
            return dict()
    def get_all_librarys_in_system(self, lib_sys_id : str) -> Dict[int, str]:
        """Returns a dictionary of {lib_id: lib_name}"""
        try:
            self.cursor.execute("call get_all_libs_in_system(%s)", lib_sys_id)
            library_list = self.cursor.fetchall()
            # Flatten 3D list of dict (of rows) into 1 dict
            library_dict = {}
            for row in library_list:
                # each row is {id: id, sys_name: name}
                id_name_list = list(row.values())
                library_dict[id_name_list[0]] = id_name_list[1]
            return library_dict
        except:
            return dict()

    def is_lib_in_sys(self, lib_name : str, sys_name : str) -> bool:
        try:
            self.cursor.execute("select is_lib_in_sys(%s, %s)", (lib_name, sys_name))
            is_valid = list(self.cursor.fetchone().values())[0]
            return bool(is_valid)
        except:
            return False

    def does_lib_system_exist(self, sys_id : str) -> bool:
        try:
            self.cursor.execute("select is_a_lib_sys(%s)", (sys_id))
            is_valid = list(self.cursor.fetchone().values())[0]
            return bool(is_valid)
        except:
            return False

    def get_lib_sys_name_from_id(self, sys_id: int) -> str:
        try:
            self.cursor.execute("select get_lib_sys_name_from_id(%s)", (sys_id))
            sys_name = list(self.cursor.fetchone().values())[0]
            return str(sys_name)
        except:
            return ""

    def get_lib_sys_name_from_user_id(self, user_id: int) -> str:
        try:
            self.cursor.execute("select get_lib_sys_name_from_user_id(%s)", (user_id))
            sys_name = list(self.cursor.fetchone().values())[0]
            return str(sys_name)
        except:
            return ""

    def get_lib_name_from_id(self, lib_id: int) -> str:
        try:
            self.cursor.execute("select get_lib_name_from_id(%s)", (lib_id))
            lib_name = list(self.cursor.fetchone().values())[0]
            return str(lib_name)
        except:
            return ""

    def search_for_book(self, book_name: str, lib_sys_id: int) -> Optional[List[Dict]]:
        """Search for all copies of the book within the library system.
        Limit the results to within the library system because a user can ONLY checkout
        a book if they belong to a library within the system"""
        try:
            self.cursor.execute("call search_for_book(%s, %s)", (book_name, lib_sys_id))
            # Result is a list of dictionaries where the key's are repeated
            search_res = self.cursor.fetchall()
            return search_res
        except Exception as err:
            print("Failed to search for book: " + str(err))
            return None

    def search_lib_sys_catalog(self, lib_sys_id: int) -> Optional[List[Dict]]:
        """Search for ALL books that are in libraries in the Library System"""
        try:
            self.cursor.execute("call search_lib_sys_catalog(%s)", (lib_sys_id))
            # Result is a list of dictionaries where the key's are repeated
            catalog_search_res = self.cursor.fetchall()
            return catalog_search_res
        except:
            return None

    def get_lib_sys_id_from_user_id(self, user_id) -> Optional[int]:
        """Given a user's id, returns the id of the library system"""
        try:
            self.cursor.execute("select get_lib_sys_id_from_user_id(%s)", (user_id))
            lib_sys_id = list(self.cursor.fetchone().values())[0]
            return int(lib_sys_id)
        except:
            return None

    def get_card_num_by_user_id(self, user_id) -> Optional[int]:
        """Returns a user's library card# or None if user doesnt exist. Call AFTER addUser()"""
        try:
            self.cursor.execute("select get_card_num_by_user_id(%s)", (user_id))
            lib_card_num = list(self.cursor.fetchone().values())[0]
            return int(lib_card_num)
        except Exception as err:
            print(f"Failed to get lib card num by user id: {err}")

    def get_is_user_employee(self, user_id) -> bool:
        """Returns true if the user with the given id is an employee, false otherwise"""
        try:
            self.cursor.execute("select get_is_user_employee(%s)", (user_id))
            is_employee = list(self.cursor.fetchone().values())[0]
            return bool(is_employee)
        except Exception as err:
            print(f"Failed to determine if user with id {user_id} is an employee: {err}")
            return False

    def get_card_num_by_username(self, username) -> Optional[int]:
        """Returns a user's library card# or None if user doesnt exist. Call AFTER addUser()"""
        try:
            self.cursor.execute("select get_card_num_by_username(%s)", (username))
            lib_card_num = list(self.cursor.fetchone().values())[0]
            return int(lib_card_num)
        except Exception as err:
            print(f"Failed to get lib card num by username: {err}")
            return None

    def checkout_book(self, user_id: int, book_title: str, lib_sys_id: int, lib_id: int) -> dict:
        """Checkout a book with 'book_title' for 'user_id'

        Args:
            user_id (int): The user's id
            book_title (str): The book's title
            lib_sys_id (int): The id for the library system to search within
            lib_id (int): The id of the library the user belongs to

        Raises:
            Exception: Basic exception with a string detailing any non-expected errors

        Returns:
            dict: {
                rtncode: 1 (success), -1 (no copies available), else failure
                due_date: Optional[datetime]
            }
        """

        try:
            self.cursor.execute("call checkout_book(%s, %s, %s, %s)",
                                (user_id, book_title, lib_sys_id, lib_id))
            # 1 = success, -1 = no copies avail, -2 = book_id already checked out, else = failure
            # print(self.cursor._last_executed)
            res_dict = self.cursor.fetchone()
            return res_dict
        except Exception as err:
            raise Exception(f"Failed to checkout book: {err}")

    def place_hold(self, user_id: int, book_title: str, lib_sys_id: int, lib_id: int) -> Dict[str, int]:
        """Places a hold on a book with 'book_title' for 'user_id'

        Args:
            user_id (int): The user's id
            book_title (str): The book's title
            lib_sys_id (int): The id for the library system to search within
            lib_id (int): The id of the library the user belongs to

        Raises:
            Exception: Basic exception with a string detailing any non-expected errors

        Returns: {rtncode: <code>}
            code = 0: user already placed a hold on that book at that library
            code = 1: success
        """
        try:
            self.cursor.execute("call place_hold(%s, %s, %s, %s)",
                                (user_id, book_title, lib_sys_id, lib_id))
            hold_res_dict = self.cursor.fetchone()
            return hold_res_dict
        except Exception as err:
            raise Exception(f"Failed to checkout book: {err}")

    def get_pending_employees(self, employee_user_id : int) -> Optional[List[Dict]]:
        """Given an employee's user_id, find all employees pending approval at their library"""
        try:
            self.cursor.execute("call get_pending_employees(%s)", employee_user_id)
            # Result is a list of dictionaries where the key's are repeated
            pending_employee_list = self.cursor.fetchall()
            return pending_employee_list
        except Exception as err:
            raise Exception(f"Failed to find pending employees: {err}")

    def approve_employee(self, employee_id : int) -> bool:
        try:
            self.cursor.execute("call approve_employee(%s)", employee_id)
            return list(self.cursor.fetchall())
        except Exception as err:
            raise Exception(f"Failed to approve an employee: {err}")

    def deny_employee_approval(self, employee_id : int) -> bool:
        try:
            self.cursor.execute("call deny_employee_approval(%s)", employee_id)
            return list(self.cursor.fetchall())
        except Exception as err:
            raise Exception(f"Failed to deny an employee's approval: {err}")

    def is_employee_pending_by_user_id(self, user_id : int) -> bool:
        try:
            self.cursor.execute("select is_employee_pending_by_user_id(%s)", (user_id))
            is_pending = list(self.cursor.fetchone().values())[0]
            return bool(is_pending)
        except Exception as err:
            print(f"Failed to determine if user with id {user_id} is pending: {err}")
            return False

    def add_new_book(self,
        title : str,
        lib_id : int,
        isbn : str,
        author : str,
        publisher : str,
        is_audio_book : bool,
        num_pages : int,
        checkout_length_days : int,
        book_dewey: float,
        late_fee_per_day: float) -> bool:
        """Used by employees to add a new book to a library.
        \n:return - 1 on success, -1 on failure"""
        try:
            res = self.cursor.execute("call add_new_book(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                    (title, lib_id, isbn, author, publisher, is_audio_book, num_pages,
                                    checkout_length_days, book_dewey, late_fee_per_day))
            return 1
        except Exception as error:
            print("Error adding new book: " + str(error))
            return -1


    def get_user_checkouts(self, user_id: int) -> dict:
        try:
            self.cursor.execute("call get_user_checkouts(%s)", (user_id))
            checkouts_res_dict = self.cursor.fetchall()
            return checkouts_res_dict
        except Exception as err:
            raise Exception(f"Failed to get checked out books: {err}")

    def get_checkout_book_id_from_user_title(self, user_id: int, book_title: str) -> int:
        """Gets the book_id of 'book_title' checked out by 'user_id'. Returns -1 if error"""
        try:
            self.cursor.execute("SELECT get_checkout_book_id_from_user_title(%s,%s)",
                                (user_id, book_title))
            book_id_res = self.cursor.fetchone()
            return book_id_res["book_id"] if "book_id" in book_id_res else -1
        except Exception as err:
            print(f"Failed to get checkout book_id: {err}")
            return -1

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Library Database Python Connector")
    parser.add_argument(
        "-u", "--username",
        required=False,
        default="root",
        dest="user",
        help="The username for the MySQL Database"
    )

    parser.add_argument(
        "-pwd", "--password",
        required=True,
        default=None,
        dest="pwd",
        help="The password for the MySQL Database"
    )

    parser.add_argument(
        "-d", "--db",
        required=False,
        default="libsystem",
        dest="db_name",
        help="The name of the database to connect to"
    )


    # actually parse args (convert to dict form)
    args = vars(parser.parse_args())

    # make the object
    db = DB_Manager(args["user"], args["pwd"], args["db_name"])

    ret = db.addUser("test", "user", "1", datetime.datetime(1999, 5, 21), True, "testusername", "testpwd")
    if (ret == -1):
        print("Username already taken")
    elif (ret == 1):
        print('Congratulations, you are now a registered user!')
    elif (ret == 0):
        print("Add user fail")
