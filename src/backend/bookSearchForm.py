
"""
    @File responsible for defining all form classes to be used by the webapp
    @Ref: https://flask.palletsprojects.com/en/2.0.x/patterns/wtforms/
"""

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import Form, BooleanField, StringField, PasswordField, validators, SubmitField

#--------------------------------OUR DEPENDENCIES--------------------------------#


class BookSearchForm(FlaskForm):
    """Form responsible for having fields to enable users to lookup books"""
    book_title = StringField('Search For A Book')
    submit = SubmitField('Search')