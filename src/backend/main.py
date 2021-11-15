#!/usr/bin/python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import webbrowser # allows opening of new tab on start
import argparse # cli paths
import logging # used to disable printing of each POST/GET request

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import flask
from flask import Flask, templating, render_template, request, redirect, flash, url_for
import werkzeug.serving # needed to make production worthy app that's secure

import pathlib
from pathlib import Path

#--------------------------------Project Includes--------------------------------#
from formManager import bookLookupForm
from bookSearchTable import BookSearchTable, BookSearchCell

class WebApp():
    def __init__(self, port, is_debug):
        self._app = Flask("LibraryDB")
        self._app.config["TEMPLATES_AUTO_RELOAD"] = True # refreshes flask if html files change

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

        # TODO: make a route for employees to add a new book to the library

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
        #TODO: make this a login required page (or at least have them login right now)
        @self._app.route('/checkout', methods=['POST', 'GET'])
        def checkout():
            title = request.args.get('book_title')
            if request.method == 'GET':
                return render_template("checkout.html", book_title=title)
            elif request.method == "POST":
                # TODO: make a query / call procedure for checking out a book
                print(f"Checking out book {title}")
                # TODO: call procedure to verify user is part of the library system the book belongs to
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

    def printSites(self):
        print("Existing URLs:")
        print(f"http://localhost:{self._port}/")

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

    # Actually Parse Flags (turn into dictionary)
    args = vars(parser.parse_args())

    app = WebApp(args["port"], args['debugMode'])