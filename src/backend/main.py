#!/usr/bin/env python3

#------------------------------STANDARD DEPENDENCIES-----------------------------#
import os, sys
import webbrowser # allows opening of new tab on start
import argparse # cli paths
import Path

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
import flask
from flask import Flask, templating, render_template, request, redirect, flash, url_for
import werkzeug.serving # needed to make production worthy app that's secure

class WebApp():
    self._app = Flask("LibraryDB")
    self._app.config["TEMPLATES_AUTO_RELOAD"] = True # refreshes flask if html files change
    self.app.run(host='0.0.0.0', port=8080, debug=True)
