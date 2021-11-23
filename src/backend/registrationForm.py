"""
    @file Responsible for creating the registration page for the web app
"""

#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.fields.core import SelectField
from wtforms.fields.html5 import DateField
from wtforms.validators import ValidationError, DataRequired, EqualTo, StopValidation, Optional
from wtforms import validators
from flask import flash, Flask
from typing import Optional, List, Tuple
import datetime

#--------------------------------OUR DEPENDENCIES--------------------------------#
from userManager import UserManager

class RegistrationForm(FlaskForm):
    fname = StringField("First Name", validators=[DataRequired()])
    lname = StringField("Last Name", validators=[DataRequired()])
    dob = DateField("Date of Birth", format='%Y-%m-%d', validators=[DataRequired()])
    is_employee = BooleanField("Are You an Employee?", validators=[])

    # At run time generate the choices https://wtforms.readthedocs.io/en/2.3.x/fields/#wtforms.fields.SelectField
    # choices = (value, label)
    lib_name = SelectField("Library Name", validators=[DataRequired()])
    lib_sys_name = SelectField("Library System Name", validators=[DataRequired()])

    # Fields that are only required for employees - default to empty - use validators
    hire_date = DateField("Hire Date", format='%Y-%m-%d', validators=[])
    salary = StringField("Salary", validators=[], default="")
    job_role = StringField("Job Description", validators=[], default="")


    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password',  validators=[DataRequired()])
    password2 = PasswordField('Repeat Password', validators=[DataRequired(), EqualTo('password')])
    submit = SubmitField('Register')

    def __init__(self, flaskApp: Flask,
                user_manager: UserManager,
                *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        self.user_manager = user_manager

        cls = self.__class__ # get reference to cls
        cls.username = StringField('Username', validators=[DataRequired(), self.validateUsername])

        # choices = (value, label)
        cls.lib_name = SelectField("Library Name", validators=[DataRequired(), self.validateLibSystemName, self.validateLibName])
        cls.lib_sys_name = SelectField("Library System Name", validators=[DataRequired()])

        # These fields are validated to ensure they are not blank if the user is an employee
        cls.hire_date = DateField("Hire Date (only for employees)", format='%Y-%m-%d',
                                    validators=[self.validateEmployeeFields], default=datetime.date.today())
        cls.salary = StringField("Salary (only for employees)",
                                    validators=[self.validateEmployeeFields, self.validateSalaryField])
        cls.job_role = StringField("Job Description (only for employees)",
                                    validators=[self.validateEmployeeFields])

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
        # Note that the data is the id of library and lib_system
        if not self.user_manager.is_lib_in_sys(form.lib_name.data, form.lib_sys_name.data):
            lib_name = self.user_manager.get_lib_name_from_id(form.lib_name.data)
            lib_sys_name = self.user_manager.get_lib_sys_name_from_id(form.lib_sys_name.data)
            errMsg = "Library " + lib_name + " is not in Library System "
            errMsg += lib_sys_name + ", please try again"
            # flash(errMsg)
            raise ValidationError(message=errMsg) # prints under box
        else:
            return True

    def validateLibSystemName(self, form, field) -> bool:
        is_valid_system = self.user_manager.does_lib_system_exist(form.lib_sys_name.data)
        if not is_valid_system:
            # errMsg = "Library System '" + str(form.lib_sys_name.data) + "' does not exist, please try again"
            errMsg = "Library System selected does not exist, please try again"
            # flash(errMsg)
            # Because this comes before validateLibName
            raise StopValidation(message=errMsg) # prints under box
        else:
            return True

    def validateEmployeeFields(self, form, field) -> bool:
        """If the new user is an employee, the field cannot be blank"""
        if form.is_employee.data == False:
            return True
        # The new user is an employee, make sure the field is valid
        # Check to make sure the field is not blank (the default)
        elif field.data == "" or field.data is None:
            errMsg = f"This field is required if registering as an employee, please try again"
            raise ValidationError(message=errMsg) # prints under box
        else:
            return True

    def validateSalaryField(self, form, field) -> bool:
        """Salary must be a float compatible value"""
        if form.is_employee.data == False:
            return True
        errMsg = f"Salary must be a number. Do not include symbols or letters"
        try:
            float_convert = float(field.data)
            if isinstance(float_convert, float):
                return True
            else:
                raise ValidationError(message=errMsg) # prints under box
        except:
            raise ValidationError(message=errMsg) # prints under box