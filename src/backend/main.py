#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import webbrowser # allows opening of new tab on start
import argparse # cli paths
import logging # used to disable printing of each POST/GET request
import pathlib
from pathlib import Path
import secrets
import getpass

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import flask
from flask import Flask, session, render_template, request, redirect, flash, url_for, jsonify
import werkzeug.serving # needed to make production worthy app that's secure

# decorate app.route with "@login_required" to make sure user is logged in before doing anything
# https://flask-login.readthedocs.io/en/latest/#flask_login.LoginManager.user_loader -- "flask_login.login_required"
from flask_login import login_user, current_user, login_required, logout_user


#--------------------------------Project Includes--------------------------------#
from bookSearchForm import BookSearchForm
from bookSearchTable import BookSearchTable, BookSearchCell, create_search_cells
from pendingEmployeeTable import PendingEmployeeCell, PendingEmployeeTable, create_pending_employee_cells
from userHistoryTable import UserHistoryTable, create_user_history_cells
from catalogResultTable import CatalogResultTable, create_catalog_cells
from profileCheckoutTable import ProfileCheckoutTable, create_profile_checkout_cells
from profileHoldsTable import ProfileHoldsTable, create_profile_holds_cells
from user import User
from userManager import UserManager
from registrationForm import RegistrationForm
from loginForm import LoginForm
from forgotPasswordForm import ForgotPwdForm
from addBookForm import AddBookForm

class WebApp(UserManager):
    def __init__(self, port: int, is_debug: bool, user: str, pwd: str, db: str):
        self._app = Flask("LibraryDB")
        self._app.config["TEMPLATES_AUTO_RELOAD"] = True # refreshes flask if html files change
        self._app.config['SECRET_KEY'] = secrets.token_urlsafe(16)

        # Inheret all functions and 'self' variables (UserManager)
        UserManager.__init__(self, self._app, user, pwd, db)

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

        # dont thread so requests dont happen concurrently
        self._app.run(host=self._host, port=self._port, debug=self._is_debug, threaded=False)
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
        self.createInfoRoutes()
        self.createEmployeeRoutes()

    def createLandingPage(self):
        @self._app.route("/", methods=["GET"])
        def index():
            return render_template("index.html", title="Library DB App", form=BookSearchForm())

        @self._app.route("/profile", methods=["GET"])
        @login_required
        def profile():
            user_id = current_user.id
            # get user's checked out books in table form
            user_checkouts = self.get_user_checkouts(user_id)
            checkout_cells = create_profile_checkout_cells(user_checkouts)
            checkouts_table = ProfileCheckoutTable(checkout_cells)

            # get user's holds in table form
            # ProfileHoldsTable, create_profile_holds_cells
            user_holds = self.get_user_holds(user_id)
            hold_cells = create_profile_holds_cells(user_holds)
            holds_table = ProfileHoldsTable(hold_cells)

            # Get the user's history
            user_hist = self.get_user_history_from_id(user_id)
            user_hist_cells = create_user_history_cells(user_hist)
            user_hist_table = UserHistoryTable(user_hist_cells)

            return render_template("profile.html",
                title="Library DB Profile",
                checkouts_table=checkouts_table,
                holds_table=holds_table,
                user_hist_table=user_hist_table
            )


    def createFormPages(self):
        @self._app.route('/search_book', methods=['POST'])
        @login_required
        def search_book():
            form = BookSearchForm(request.form)
            # Get the library system of the user to search for
            lib_sys_id = self.get_lib_sys_id_from_user_id(current_user.id)
            BookSearchTableCells = []
            if lib_sys_id is not None:
                raw_res_list = self.search_for_book(form.book_title.data, lib_sys_id)
                BookSearchTableCells = create_search_cells(raw_res_list, form.book_title.data)

            # If the list is empty, "No Items" is displayed
            search_table = BookSearchTable(BookSearchTableCells)

            return render_template("searchResult.html",
                book_title_searched=form.book_title.data,
                result_table=search_table
            )

        @self._app.route("/get_lib_sys_catalog", methods=["GET"])
        @login_required
        def get_lib_sys_catalog():
            lib_sys_name = self.get_lib_sys_name_from_user_id(current_user.id)
            lib_sys_id = self.get_lib_sys_id_from_user_id(current_user.id)
            catalog_dict = self.search_lib_sys_catalog(lib_sys_id)
            catalog_cells = []
            if catalog_dict is not None:
                catalog_cells = create_catalog_cells(catalog_dict)

            # If the list is empty, "No Items" is displayed
            catalog_table = CatalogResultTable(catalog_cells)
            return render_template("catalogResult.html", lib_sys_name=lib_sys_name, catalog_table=catalog_table)

    def createInfoRoutes(self):
        """All routes for internal passing of information"""
        @self._app.route('/register/set_avail_libs/<lib_system_id>', methods=['POST'])
        def register_set_avail_libs(lib_system_id):
            """Used to ad-hoc set the libraries in the registration dropdown
                based on the library system selected in dropdown."""
            id_name_dict = {}
            # Edge case for reseting library system to default
            if lib_system_id == "all_libs":
                id_name_dict = self.get_all_libraries()
            else:
                # Get the libraries part of the system
                id_name_dict = self.get_all_librarys_in_system(lib_system_id)
            return jsonify(list(id_name_dict.items()))

    def createCheckoutPages(self):
        def handleCheckout(book_title: str, user_id: int, lib_sys_id: int, lib_id: int):
            # checkout book w/ error check
            try:
                checkout_res_dict = self.checkout_book(user_id, book_title, lib_sys_id, lib_id)
            except Exception as err:
                print(f"Failed to checkout book err: {err}")

            if(checkout_res_dict["rtncode"] != 1):
                flash(f"Failed to checkout book!", "is-danger")
                if checkout_res_dict["rtncode"] == -1:
                    flash("No more copies available", "is-warning")
                if checkout_res_dict["rtncode"] == -2:
                    flash("Already checked out '" +str(book_title)+ "'", "is-warning")

                return redirect(url_for("index"))

            # TODO: have success_status include number of people ahead of them on hold
            flash("Successfully checked out: " + str(book_title), "is-success")
            flash("Due Date: " + str(checkout_res_dict["due_date"]), "is-info")
            return redirect(url_for("index"))

        def handleHold(book_title: str, user_id: int, lib_sys_id: int, lib_id: int):
            # place hold on book w/ error check
            try:
                hold_res_dict = self.place_hold(user_id, book_title, lib_sys_id, lib_id)
            except Exception as err:
                errMsg = "Failed to place hold on " + str(book_title)
                print(f"{errMsg}: {err}")
                flash(errMsg, "is-danger")
                return redirect(url_for("index"))

            if(hold_res_dict["rtncode"] != 1):
                flash("Failed to place hold on book!", "is-danger")
                if(hold_res_dict["rtncode"] == 0):
                    flash("You already placed a hold on '"+ str(book_title) + "'", "is-warning")
                    return redirect(url_for("index"))
                elif(hold_res_dict["rtncode"] == 2):
                    flash("You already checked out '" + str(book_title) + "'", "is-warning")
                    return redirect(url_for("index"))

            flash("Successfully placed hold on " + str(book_title), "is-success")
            return redirect(url_for("index"))

        @self._app.route('/get_book/<string:method>/<string:book_title>', methods=['POST'])
        @login_required
        def getbook(book_title: str, method: str):
            """Actually checks out or places hold on a book based on url params
            Args:
                book_title (str): The title of the book
                method (str): 'checkout' or 'hold'
            """

            is_checkout = method == "checkout"

            user_id = current_user.id
            lib_sys_id = self.get_lib_sys_id_from_user_id(user_id)
            lib_id = self.get_lib_id_from_user_id(user_id)

            # error check
            if(book_title == None or lib_sys_id == None or lib_id == None):
                flash("Invalid Checkout!", "is-danger")
                # try to go back, else returns to index
                return redirect(url_for("index"))

            if is_checkout:
                return handleCheckout(book_title, user_id, lib_sys_id, lib_id)
            else: # is_hold
                return handleHold(book_title, user_id, lib_sys_id, lib_id)

        @self._app.route('/returns/<string:book_title>', methods=['POST'])
        @login_required
        def returns(book_title: str):
            """Route for returning a book"""
            # NOTE: Dont decide which book to return based on untrusted
            # user input (ie book_id which can be faked)
            user_id = current_user.id
            book_id = self.get_checkout_book_id_from_user_title(user_id, book_title)
            if book_id == -1:
                flash("Failed to get the checked out book id for " + book_title, "is-warning")
                return redirect(url_for("profile"))

            if(self.return_book(book_id, user_id)):
                flash("Successfully returned " + book_title, "is-success")
            else:
                flash("Failed to return " + book_title, "is-danger")

            return redirect(url_for("profile"))

        @self._app.route('/cancel_hold/<int:hold_id>', methods=['POST'])
        @login_required
        def cancel_hold(hold_id: int):
            """Route for cancelling a hold"""
            # make sure authorized user is making the cancel
            user_id = current_user.id
            cancel_hold_rtn = self.cancel_hold(user_id, hold_id)
            if cancel_hold_rtn == 1:
                flash("Successfully cancelled hold", "is-success")
            elif cancel_hold_rtn == 0:
                flash("Requested hold does not exist", "is-warning")
            else:
                flash("Failed to cancel hold", "is-error")

            return redirect(url_for("profile"))


    def createUserPages(self):
        # https://flask-login.readthedocs.io/en/latest/#login-example
        @self._app.route("/login", methods=["GET", "POST"])
        def login():
            # dont login if already logged in
            if current_user.is_authenticated:
                return redirect(url_for('index'))

            # to provide UserManager, use self which is a child of it
            form = LoginForm(self._app, self)

            if request.method == "GET":
                return render_template('login.html', title="LibraryDB Login", form=form)
            elif request.method == "POST" and not form.validate_on_submit():
                # unsuccessful login
                flash("Invalid Username or Password!", "is-danger")
                return render_template('login.html', title="LibraryDB Login", form=form)

            elif request.method == "POST":
                # username & pwd must be right at this point, so login
                # https://flask-login.readthedocs.io/en/latest/#flask_login.LoginManager.user_loader
                # call loadUser() / @user_loader in userManager.py
                user_id = self.getUserIdFromUsername(form.username.data)
                lib_card_num = self.get_card_num_by_user_id(user_id)
                is_employee = self.get_is_user_employee(user_id)
                user = User(user_id, lib_card_num, is_employee=is_employee)
                login_user(user, remember=form.rememberMe.data)

                # two seperate flashes for diff categories
                flash("Successfully logged in!", "is-success")
                flash(f"Library Card Number: {lib_card_num}", "is-info") # format str safe bc not user input
                if self.is_employee_pending_by_user_id(current_user.id):
                    flash("You are still pending approval as an employee!", "is-info")

            # route to original destination
            next = flask.request.args.get('next')
            isNextUrlBad = next == None or not is_safe_url(next, self._urls)
            if isNextUrlBad:
                return redirect(url_for('index'))
            else:
                return redirect(next)

            # on error, keep trying to login until correct
            return redirect(url_for("login"))

        @self._app.route("/register", methods=["GET", "POST"])
        def register():
            if current_user.is_authenticated: return redirect(url_for('index'))
            # make the form for both GET & POST (to show and parse respectively)
            lib_systems_dict = self.get_all_library_systems()
            # Convert sys_id:sys_name -> (sys_id, sys_name)
            lib_systems = list(map(lambda sys_id_name_pair:
                (sys_id_name_pair[0], sys_id_name_pair[1]), lib_systems_dict.items()))

            # Start by showing All libraries. Eventually this is reduced.
            libraries_dict = self.get_all_libraries()
            # Convert lib_id:lib_name -> (lib_name, lib_name)
            libraries = list(map(lambda lib_id_name_pair:
                    (lib_id_name_pair[0], lib_id_name_pair[1]), libraries_dict.items()))

            form = RegistrationForm(self._app, user_manager=self)

            # Set the options for the dropdowns
            # Add empty options for blank default
            form.lib_sys_name.choices = [('', '')] + lib_systems
            form.lib_name.choices = [('', '')] + libraries

            if request.method == "GET":
                return render_template('registration.html', title="LibraryDB Login", form=form)

            elif request.method == "POST" and form.validate_on_submit():
                print("register validation passed")
                # actually add user given info is valid/allowed
                add_employee_res = 0 # "failed" to adad employee cus... we arent
                add_res = self.addUser(
                    form.fname.data,
                    form.lname.data,
                    form.lib_name.data,
                    form.dob.data,
                    form.is_employee.data,
                    form.username.data,
                    form.password.data
                )
                # When the new user is an employee, add them as an employee as well
                if form.is_employee.data == True and add_res == 1:
                    # get the user and lib id created for them as a user
                    new_user_id = self.getUserIdFromUsername(form.username.data)
                    lib_id = self.get_lib_id_from_user_id(new_user_id)
                    # Approval is done after the fact
                    is_approved = False
                    add_employee_res = self.addEmployee(
                        form.hire_date.data,
                        form.salary.data,
                        form.job_role.data,
                        new_user_id,
                        lib_id,
                        is_approved
                    )

                if (add_res == -1):
                    flash("Username already taken", "is-danger")
                elif (add_res == 1):
                    card_num = self.get_card_num_by_username(form.username.data)
                    msg = "Congratulations, you are now a registered user! \
                          Your library card number is " + str(card_num) + "."
                    flash(msg, " is-success")

                    if (add_employee_res == 1):
                        employee_msg = "You are a registered employee"
                        employee_msg += " pending approval by a fellow coworker"
                        flash(employee_msg, " is-info")

                elif (add_res == 0):
                    flash('Registration Failed!', "is-danger")
                elif (add_employee_res == -1):
                    flash('Registration as user was successful! \
                        Registration as employee failed!', "is-danger")

                # since form validated, always return to login
                return redirect(url_for("login"))

            elif request.method == "POST":
                print("Registration Validation Failed")

            # on GET or failure, reload
            return render_template('registration.html', title='LibraryDB Registration', form=form)

        @self._app.route("/employee_actions", methods=["GET", "POST"])
        @login_required
        def employee_actions():
            """Page used to allow employees to perform employee ONLY actions like add books"""
            if not current_user.is_employee:
                # Only employees can access this page
                return redirect("/")
            else:
                user_id = current_user.id
                pending_employee_table = self._get_pending_employee_table(user_id)

                return render_template("employeeActions.html",
                                       add_new_book_form=AddBookForm(),
                                       pending_employee_table=pending_employee_table)

        @self._app.route("/forgot-password", methods=["GET", "POST"])
        def forgotPassword():
            form = ForgotPwdForm(self._app, user_manager=self)

            if request.method == "POST" and form.validate_on_submit():
                # actually change a user's login given info is valid/allowed
                self.updatePwd(form.username.data, form.new_password.data)
                return redirect(url_for('index'))
            elif request.method == "POST":
                print("Forgot Password Reset Failed")

            # on GET or failure, reload
            return render_template('forgotPasswordForm.html', title='LibraryDB Forgot Password', form=form)

        @self._app.route("/logout", methods=["GET", "POST"])
        @login_required
        def logout():
            logout_user()
            flash("Successfully logged out!", "is-success")
            return redirect(url_for("login"))

        @self._app.route('/change_pending_employee_status/<string:action>/<int:employee_id>', methods=['POST'])
        @login_required
        def change_pending_employee_status(action: str, employee_id: int):
            """If the employee is approved, update them in the table. Otherwise remove them from it"""
            if not current_user.is_employee:
                # Only verified employees can access this page
                return redirect(url_for("index"))
            if action == "approve":
                self.approve_employee(employee_id)
            elif action == "deny":
                self.deny_employee_approval(employee_id)

            # return to the previous page
            return redirect(url_for("employee_actions",
                                    add_new_book_form=AddBookForm(),
                                    pending_employee_table=self._get_pending_employee_table(current_user.id)))

    def createEmployeeRoutes(self):
        @self._app.route("/add_new_book", methods=["GET", "POST"])
        @login_required
        def add_new_book():
            """Page used to allow employees to perform employee ONLY actions like add books"""
            if not current_user.is_employee:
                # Only employees can access this page
                return redirect("/")

            # Otherwise, validate the form
            add_book_form = AddBookForm(request.form)
            user_id = current_user.id
            library_id = self.get_lib_id_from_user_id(user_id)
            library_name = self.get_lib_name_from_id(user_id)
            if request.method == "POST" and add_book_form.validate_on_submit():
                print(f"book_title = {add_book_form.book_title.data}, \
                    \n library_id = {library_id}, \
                    \n isbn = {add_book_form.isbn.data}, \
                    \n author = {add_book_form.author.data}, \
                    \n publisher = {add_book_form.publisher.data}, \
                    \n is_audio_book = {add_book_form.is_audio_book.data}, \
                    \n num_pages = {add_book_form.num_pages.data}, \
                    \n checkout_length_days = {add_book_form.checkout_length_days.data}, \
                    \n book_dewey = {add_book_form.book_dewey.data}, \
                    \n late_fee_per_day = {add_book_form.late_fee_per_day.data}"
                        )
                add_book_res = self.add_new_book(
                    title =                 add_book_form.book_title.data,
                    lib_id =                library_id,
                    isbn =                  add_book_form.isbn.data,
                    author =                add_book_form.author.data,
                    publisher =             add_book_form.publisher.data,
                    is_audio_book =         add_book_form.is_audio_book.data,
                    num_pages =             add_book_form.num_pages.data,
                    checkout_length_days =  add_book_form.checkout_length_days.data,
                    book_dewey =            add_book_form.book_dewey.data,
                    late_fee_per_day =      add_book_form.late_fee_per_day.data
                )

                if (add_book_res == 1):
                    msg = f"The book {add_book_form.book_title.data} was added to library {library_name}"
                    flash(msg, " is-success")
                    return redirect(url_for("login"))
                elif (add_book_res == -1):
                    flash(f'Failed to add the book {add_book_form.book_title.data} to library {library_name}!', "is-danger")

            elif request.method == "POST":
                flash("Add New Book Validation Failed", "is-danger")

            # Return to the employee action page
            return redirect(url_for("employee_actions",
                                   add_new_book_form=add_book_form,
                                   pending_employee_table=self._get_pending_employee_table(current_user.id)))

    def _get_pending_employee_table(self, user_id):
        """Util Function to prevent code duplication
        \n:user_id the user_id of the employee that is taking actions"""
        raw_pending_employee_res = self.get_pending_employees(user_id)
        return PendingEmployeeTable(create_pending_employee_cells(raw_pending_employee_res))

    def printSites(self):
        print("Existing URLs:")
        print(f"http://localhost:{self._port}/")
        print(f"http://localhost:{self._port}/login")
        print(f"http://localhost:{self._port}/register")
        print(f"http://localhost:{self._port}/forgot-password")
        print(f"http://localhost:{self._port}/logout")
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
        "--debugModeOn",
        action="store_true",
        dest="debugMode",
        required=False,
        help="Use debug mode for development environments",
        default=True
    )
    parser.add_argument(
        "--debugModeOff",
        action="store_false",
        dest="debugMode",
        required=False,
        help="Dont use debug mode for development environments",
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
        required=False, # but if not provided asks for input
        default=None,
        dest="pwd",
        help="The password for the MySQL Database"
    )
    parser.add_argument(
        "-d", "--db",
        required=False,
        default="libsystem",
        dest="db",
        help="The name of the database to connect to"
    )

    # Actually Parse Flags (turn into dictionary)
    args = vars(parser.parse_args())

    # ask for input if password not given
    if args["pwd"] == None:
        args["pwd"] = getpass.getpass("Enter the password for the database '" + str(args["db"]) + "': ")

    # start app
    app = WebApp(args["port"], args["debugMode"], args["user"], args["pwd"], args["db"])
