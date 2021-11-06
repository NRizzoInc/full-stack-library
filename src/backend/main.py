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

    def createLandingPage(self):
        @self._app.route("/", methods=["GET"])
        def createMainPage():
            return render_template("mainPage.html", title="Library DB App")
            return "Hello World"

    def printSites(self):
        print("Existing URLs:")
        print(f"http://localhost:8080/")

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