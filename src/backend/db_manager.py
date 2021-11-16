#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import argparse # cli paths
import datetime

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
            self.cursor.execute("call get_user_id(%s)", username)
            user_ids = self.cursor.fetchall()
            # use '.values()' to make python agnostic to the name of returned col in procedure
            return user_ids[0].values()[0] if len(user_ids) > 0 else -1
        except:
            return -1

    def addUser(self,
        fname: str,
        lname: str,
        dob: str,
        is_employee: bool,
        username: str,
        pwd: str
    ) -> int():
        """Adds a user to the database. Return 1 if successful, -1 if username taken, else 0"""
        if(self.doesUsernameExist(username)): return -1

        num_rows = self.cursor.execute("call insert_user(%s, %s, %s, %s, %s, %s)",
                            (fname, lname, dob, is_employee, username, pwd))
        # actually apply change to database
        self.conn.commit()
        # number of rows affected should = 1
        return 1 if num_rows == 1 else 0

    def removeUser(self, userToken):
        """
            \n@Brief: Remove a user
            \n@Param: userToken - The user's unique token
        """
        # TODO: implement removing a user (delete row from table)
        pass

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
    
    ret = db.addUser("test", "user", datetime.datetime(1999, 5, 21), True, "testusername", "testpwd")
    if (ret == -1):
        print("Username already taken")
    elif (ret == 1):
        print('Congratulations, you are now a registered user!')
    elif (ret == 0):
        print("Add user fail")
