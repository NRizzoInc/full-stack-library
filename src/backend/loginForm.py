#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import ValidationError, StopValidation, DataRequired
from flask import flash, Flask

#--------------------------------OUR DEPENDENCIES--------------------------------#
from userManager import UserManager


class LoginForm(FlaskForm, UserManager):
    """Generates a login form to authenticate with"""
    #-----------------------------------Form Fields-----------------------------------#
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password',  validators=[DataRequired()])
    rememberMe = BooleanField('Remember Me')
    submit = SubmitField('Submit')

    def __init__(self, flaskApp: Flask, user_manager: UserManager, *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        self.user_manager = user_manager
        cls = self.__class__ # get reference to cls
        cls.username = StringField('Username', validators=[DataRequired()])
        cls.password = PasswordField('Password',  validators=[DataRequired(), self.checkUsername, self.checkPwd])

    def checkPwd(self, form, field) -> bool():
        """Returns True if successful, otherwise raise ValidationError which shows on screen"""
        if not self.user_manager.checkPwdMatches(form.username.data, form.password.data):
            errMsg = "Invalid username or password"
            # flash(errMsg)
            raise ValidationError(message=errMsg) # prints under box
        else:
            return True

    def checkUsername(self, form, field)->bool():
        """
            \n@Returns True = Exists
            \n@Note: This will be part of the password's validation (chain both to avoid double flashes)
        """
        # check that username is not already taken
        if not self.user_manager.doesUsernameExist(form.username.data):
            errMsg = "Invalid username or password"
            flash(errMsg)
            raise StopValidation(message=errMsg) # prints under box
        else:
            return True