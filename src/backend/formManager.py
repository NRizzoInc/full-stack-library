from wtforms import Form, BooleanField, StringField, PasswordField, validators

"""File responsible for defining all form classes to be used by the webapp
"""

class bookLookupForm(Form):
    """Form responsible for having fields to enable users to lookup books"""
    book_title = StringField('Book Name')

# TODO: add form to add book
# TODO: add request new book be added
# TODO: add user login
# TODO: add employee login