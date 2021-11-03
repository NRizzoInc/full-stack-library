#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import argparse # cli paths

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import pymysql

class DB_Manager():
    def __init__(self, user:str, pwd:str, db:str):
        """
            \n@param: user  - The username to connect to database with
            \n@param: pwd   - The password to connect to database with
            \n@param: db    - The database to connect with
        """
        self.conn = pymysql.connect(
            host="localhost",
            user=user,
            password=pwd,
            db=db,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor
        )
        self.cursor = self.conn.cursor()

    def cleanup(self):
        self.cursor.close()
        self.conn.close()

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
        "-p", "--password",
        required=True,
        default=None,
        dest="pwd",
        help="The password for the MySQL Database"
    )

    parser.add_argument(
        "-d", "--db",
        required=False,
        default="lotrfinal",
        dest="db_name",
        help="The name of the database to connect to"
    )


    # actually parse args (convert to dict form)
    args = vars(parser.parse_args())
    
    # make the object
    db = DB_Manager(args["user"], args["pwd"], args["db_name"])
