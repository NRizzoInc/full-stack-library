from wtforms import Form, BooleanField, StringField, PasswordField, validators, SubmitField

"""File responsible for defining all form classes to be used by the webapp
Ref: https://flask.palletsprojects.com/en/2.0.x/patterns/wtforms/
"""

class bookLookupForm(Form):
    """Form responsible for having fields to enable users to lookup books"""
    book_title = StringField('Search For A Book')
    submit = SubmitField('Search')

# TODO: add form to add book
# TODO: add request new book be added
# TODO: add user login
# TODO: add employee login