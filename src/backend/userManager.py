"""
    @file Responsible for handling & keeping track of multiple users to keeping their data safe and seperate
"""

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import base64
from datetime import datetime, timedelta
import os

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
# from werkzeug.contrib.securecookie import SecureCookie
from flask import Flask, redirect
from flask_login import LoginManager

#--------------------------------OUR DEPENDENCIES--------------------------------#
from db_manager import DB_Manager
from user import User

class UserManager(LoginManager, DB_Manager):
    def __init__(self, app: Flask, user:str, pwd:str, db:str):
        """
            \n@param: app   - The flask app
            \n@param: user  - The username to connect to database with
            \n@param: pwd   - The password to connect to database with
            \n@param: db    - The name of the database to connect with
        """
        self.flaskApp = app

        # create login manager object
        LoginManager.__init__(self, self.flaskApp)

        # Create Database Manager
        DB_Manager.__init__(self, user, pwd, db)

        self.createLoginManager()

    def createLoginManager(self):
        """
            \n@Brief: Helper function that creates all the necessary login manager attributes (callbacks)
            \n@Note: Wrapper to provide closure for `self`
        """

        @self.user_loader
        def loadUser(user_id):
            """
                \n@Brief: When Flask app is asked for "current_user", this decorator gets the current user's User object
                \n@Note: Refence current user with `current_user` (from flask_login import current_user) 
                \n@Param: user_id - The user's unique token id
                \n@Return: Reference to the User class related to this userToken
            """
            # create an object to hold the user's id & functions (ie checkout, return, etc)
            return User(user_id)

        @self.unauthorized_handler
        def onNeedToLogIn():
            """
                \n@Brief: VERY important callback that redirects the user to log in if needed --
                gets triggered by "@login_required" if page is accessed without logging in
            """
            return redirect("/login")

