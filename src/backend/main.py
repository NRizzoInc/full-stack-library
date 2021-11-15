#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import webbrowser # allows opening of new tab on start
import argparse # cli paths
import logging # used to disable printing of each POST/GET request
import pathlib
from pathlib import Path
import secrets

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import flask
from flask import Flask, templating, render_template, request, redirect, flash, url_for
import werkzeug.serving # needed to make production worthy app that's secure

# decorate app.route with "@login_required" to make sure user is logged in before doing anything
# https://flask-login.readthedocs.io/en/latest/#flask_login.LoginManager.user_loader -- "flask_login.login_required"
from flask_login import login_user, current_user, login_required, logout_user


#--------------------------------Project Includes--------------------------------#
from formManager import bookLookupForm
from bookSearchTable import BookSearchTable, BookSearchCell
from userManager import UserManager
from registrationForm import RegistrationForm
from loginForm import LoginForm

class WebApp(UserManager):
    def __init__(self, port: int, is_debug: bool, user: str, pwd: str, db: str):
        self._app = Flask("LibraryDB")
        self._app.config["TEMPLATES_AUTO_RELOAD"] = True # refreshes flask if html files change
        self._app.config['SECRET_KEY'] = secrets.token_urlsafe(16)
        self.user_manager = UserManager(self._app, user, pwd, db)

        # current dir
        backend_dir = Path(__file__).parent.resolve()
        src_dir = backend_dir.parent
        frontend_dir = src_dir / 'frontend'
        template_dir = frontend_dir / 'templates'
        static_dir = frontend_dir / "static"
        self._app.static_folder = str(static_dir)
        self._app.template_folder = str(template_dir)


        self._logger = logging.getLogger("werkzeug")

        self._is_debug = is_debug
        self._host = '0.0.0.0'
        self._port = port
        logLevel = logging.INFO if self._is_debug == True else logging.ERROR
        self._logger.setLevel(logLevel)

        # print urls before starting
        self.printSites()

        # create routes
        self.generateRoutes()

        self._app.run(host=self._host, port=self._port, debug=self._is_debug)
        # FOR PRODUCTION
        # werkzeug.serving.run_simple(
        #     hostname=self._host, port=self._port,
        #     application=self._app, use_debugger=self._is_debug)

    def generateRoutes(self):
        """Wrapper around all url route generation"""
        self.createLandingPage()
        self.createFormPages()
        self.createCheckoutPages()
        self.createUserPages()

    def createLandingPage(self):
        @self._app.route("/", methods=["GET"])
        def createMainPage():
            return render_template("mainPage.html", title="Library DB App", form=bookLookupForm())

    def createFormPages(self):
        @self._app.route('/search_book', methods=['POST'])
        def search_book():
            form = bookLookupForm(request.form)
            url = "/"
            # TODO: actually do sql query
            # book_id, title, num_avail
            serach_res = [
                BookSearchCell(2, 'book2', 50),
                BookSearchCell(5, 'book5', 100)
            ]
            search_table = BookSearchTable(serach_res)

            return render_template("searchResult.html", book_title_searched=form.book_title.data,
                url=url, result_table=search_table)

    def createCheckoutPages(self):
        @self._app.route('/checkout', methods=['POST', 'GET'])
        def checkout():
            title = request.args.get('book_title')
            if request.method == 'GET':
                return render_template("checkout.html", book_title=title)
            elif request.method == "POST":
                # TODO: make a query / call procedure for checking out a book
                print(f"Checking out book {title}")
                # TODO: call checkout procedure and return to home
                # TODO: have due_date be part of procedure results
                # TODO: have success_status include if they're on hold or not + details
                return redirect(url_for("checkoutResult",
                    success_status="Success",
                    book_title=title,
                    due_date="Sept 20, 2022"))

        @self._app.route('/checkoutResult', methods=['GET'])
        def checkoutResult():
            title = request.args.get('book_title')
            _due_date = request.args.get('due_date')
            _success_status = request.args.get('success_status')
            return render_template("checkoutResult.html",
                                success_status = _success_status,
                                book_title = title,
                                due_date = _due_date)

    def createUserPages(self):
        # https://flask-login.readthedocs.io/en/latest/#login-example
        @self._app.route("/login", methods=["GET", "POST"])
        def login():
            # dont login if already logged in
            if current_user.is_authenticated:
                return redirect("/")

            form = LoginForm(self._app, self.user_manager)
            if  not form.validate_on_submit():
                # unsuccessful login
                return render_template('login.html', title="LibraryDB Login", form=form)

            # username & pwd must be right at this point, so login
            user = self.getUserByUsername(username, User)
            # https://flask-login.readthedocs.io/en/latest/#flask_login.LoginManager.user_loader
            # call loadUser() / @user_loader in userManager.py 
            login_user(user, remember=form.rememberMe.data)

            # route to original destination
            next = flask.request.args.get('next')
            isNextUrlBad = next == None or not is_safe_url(next, self._urls)
            if isNextUrlBad:
                return redirect("/")
            else:
                return redirect(next)

            # on error, keep trying to login until correct
            return redirect("/login")

        @self._app.route("/register", methods=["GET", "POST"])
        def register():
            if current_user.is_authenticated: return redirect("/")

            form = RegistrationForm(self._app, self.user_manager)
            if not form.validate_on_submit():
                # register/check username failed, retry
                return render_template('registration.html', title='LibraryDB Registration', form=form)

            # actually add user given info is valid/allowed
            self.addUser(form.username.data, form.password.data)
            flash('Congratulations, you are now a registered user!')
            return redirect("/login")

    def printSites(self):
        print("Existing URLs:")
        print(f"http://localhost:{self._port}/")
        print(f"http://localhost:{self._port}/login")
        print(f"http://localhost:{self._port}/checkout")
        print(f"http://localhost:{self._port}/search_book")

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description="Start up a web app GUI for the Library DB App")
    parser.add_argument(
        "-p", "--port",
        type=int,
        required=False,
        help="The port to run the web app from",
        default=8080
    )

    # defaults debugMode to false (only true if flag exists)
    parser.add_argument(
        "--debugMode",
        action="store_true",
        required=False,
        help="Use debug mode for development environments",
        default=True
    )

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

    # Actually Parse Flags (turn into dictionary)
    args = vars(parser.parse_args())

    app = WebApp(args["port"], args['debugMode'], args["user"], args["pwd"], args["db_name"])