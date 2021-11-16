"""
    @file Responsible for creating the registration page for the web app
"""

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.fields.html5 import DateField
from wtforms.validators import ValidationError, DataRequired, EqualTo
from flask import flash, Flask

#--------------------------------OUR DEPENDENCIES--------------------------------#
from userManager import UserManager

class RegistrationForm(FlaskForm):
    fname = StringField("First Name", validators=[DataRequired()])
    lname = StringField("Last Name", validators=[DataRequired()])
    dob = DateField("Date of Birth", format='%Y-%m-%d', validators=[DataRequired()])
    # TODO: add validation/method to restrict registering as employee
    is_employee = BooleanField("Are You an Employee?", validators=[DataRequired()])

    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password',  validators=[DataRequired()])
    password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Register')

    def __init__(self, flaskApp: Flask, user_manager: UserManager, *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        self.user_manager = user_manager

        cls = self.__class__ # get reference to cls
        cls.username = StringField('Username', validators=[DataRequired(), self.validateUsername])

    def validateUsername(self, form, field) -> bool():
        """
            \n@Note: To validate successfully, has to raise ValidationError(<msg>) on taken
        """
        # prove that username is not already taken (if taken != None & not taken == None)
        if self.user_manager.doesUsernameExist(field.data):
            errMsg = f"Username '{field.data}' is already taken, choose another one"
            flash(errMsg)
            raise ValidationError(message=errMsg) # prints under box
            return errMsg
        else:
            # print(f"Username '{typedUsername} is free!")
            return True
