#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, IntegerField
from wtforms.validators import ValidationError, StopValidation, DataRequired
from flask import flash, Flask

#--------------------------------OUR DEPENDENCIES--------------------------------#
from userManager import UserManager


class ForgotPwdForm(FlaskForm, UserManager):
    """Generates a forgot password form to authenticate and change password"""
    #-----------------------------------Form Fields-----------------------------------#
    username = StringField('Username', validators=[DataRequired()])
    card_num = IntegerField('Library Card #', validators=[DataRequired()])
    new_password = PasswordField('New Password',  validators=[DataRequired()])
    submit = SubmitField('Reset Password')

    def __init__(self, flaskApp: Flask, user_manager: UserManager, *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        self.user_manager = user_manager
        cls = self.__class__ # get reference to cls
        cls.username = StringField('Username', validators=[DataRequired()])
        cls.card_num = StringField('Library Card #', validators=[DataRequired(), self.checkLibCard])
        cls.new_password = PasswordField('Reset Password',  validators=[DataRequired()])

    def checkLibCard(self, form, field) -> bool:
        """Checks if username and library card match and are valid for a given user"""
        if not self.user_manager.checkLibCardMatchesUsername(form.username.data, form.card_num.data):
            errMsg = "Invalid username or library card number"
            # flash(errMsg)
            raise ValidationError(message=errMsg)
        else:
            return True
