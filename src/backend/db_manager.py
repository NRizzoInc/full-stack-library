#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import argparse # cli paths
import datetime
from typing import Optional, Dict

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
            print("Error adding user: " + error)
            return 0

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
            library_list = self.cursor.fetchmany()
            # Flatten 2D dict (of rows) into 1 dict
            library_dict = {lib_id:lib_name for id_name_pair in library_list
                                for lib_id,lib_name in id_name_pair.items()}
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

    def is_lib_in_sys(self, lib_name : str, sys_name : str) -> bool:
        try:
            self.cursor.execute("select is_lib_in_sys(%s, %s)", (lib_name, sys_name))
            is_valid = list(self.cursor.fetchone().values())[0]
            return bool(is_valid)
        except:
            return False

    def does_lib_system_exist(self, sys_name : str) -> bool:
        try:
            self.cursor.execute("select is_a_lib_sys(%s)", (sys_name))
            is_valid = list(self.cursor.fetchone().values())[0]
            return bool(is_valid)
        except:
            return False

    def search_for_book(self, book_name: str, lib_sys_id: int):
        """Search for all copies of the book within the library system.
        Limit the results to within the library system because a user can ONLY checkout
        a book if they belong to a library within the system"""
        try:
            self.cursor.execute("call search_for_book(%s, %s)", (book_name, lib_sys_id))
            # Result is a list of dictionaries where the key's are repeated
            search_res = self.cursor.fetchall()
            return search_res
        except:
            return None

    def get_users_lib_sys_id(self, user_id) -> Optional[int]:
        """Given a user's id, returns the id of the library system"""
        try:
            self.cursor.execute("select get_lib_sys_id_from_user_id(%s)", (user_id))
            lib_sys_id = list(self.cursor.fetchone().values())[0]
            return int(lib_sys_id)
        except:
            return None

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
