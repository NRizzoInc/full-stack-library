"""
    @file Responsible for creating the registration page for the web app
"""

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.fields.html5 import DateField
from wtforms.validators import ValidationError, DataRequired, EqualTo, StopValidation
from flask import flash, Flask

#--------------------------------OUR DEPENDENCIES--------------------------------#
from userManager import UserManager

class RegistrationForm(FlaskForm):
    fname = StringField("First Name", validators=[DataRequired()])
    lname = StringField("Last Name", validators=[DataRequired()])
    dob = DateField("Date of Birth", format='%Y-%m-%d', validators=[DataRequired()])
    # TODO: add validation/method to restrict registering as employee
    is_employee = BooleanField("Are You an Employee?", validators=[])

    lib_name = StringField("Library Name", validators=[DataRequired()])
    lib_sys_name = StringField("Library System Name", validators=[DataRequired()])

    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password',  validators=[DataRequired()])
    password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Register')

    def __init__(self, flaskApp: Flask, user_manager: UserManager, *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        self.user_manager = user_manager

        cls = self.__class__ # get reference to cls
        cls.username = StringField('Username', validators=[DataRequired(), self.validateUsername])
        cls.lib_name = StringField("Library Name", validators=[DataRequired(), self.validateLibSystemName, self.validateLibName])
        cls.lib_sys_name = StringField("Library System Name", validators=[DataRequired()])

    def validateUsername(self, form, field) -> bool():
        """
            \n@Note: To validate successfully, has to raise ValidationError(<msg>) on taken
        """
        # prove that username is not already taken (if taken != None & not taken == None)
        if self.user_manager.doesUsernameExist(form.username.data):
            errMsg = "Username " + form.username.data + " is already taken, choose another one"
            flash(errMsg, "is-danger")
            raise ValidationError(message=errMsg) # prints under box
            return errMsg
        else:
            # print(f"Username '{typedUsername} is free!")
            return True

    def validateLibName(self, form, field) -> bool:
        # Other validators ensure the library system exists
        # Make sure this library is in that system
        if not self.user_manager.is_lib_in_sys(form.lib_name.data, form.lib_sys_name.data):
            errMsg = "Library " + str(form.lib_name.data) + " is not in Library System"
            errMsg += str(form.lib_sys_name.data) + ", please try again"
            # flash(errMsg, "is-danger")
            raise ValidationError(message=errMsg) # prints under box
        else:
            return True

    def validateLibSystemName(self, form, field) -> bool:
        is_valid_system = self.user_manager.does_lib_system_exist(form.lib_sys_name.data)
        if not is_valid_system:
            errMsg = "Library System '" + str(form.lib_sys_name.data) + "' does not exist, please try again"
            # flash(errMsg, "is-danger")
            # Because this comes before validateLibName
            raise StopValidation(message=errMsg) # prints under box
        else:
            return True


