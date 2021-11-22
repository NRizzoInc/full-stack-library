#-----------------------------3RD PARTY DEPENDENCIES-----------------------------#
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import ValidationError, StopValidation, DataRequired
from flask import flash, Flask

#--------------------------------OUR DEPENDENCIES--------------------------------#

class AddBookForm(FlaskForm):
    """Generates a form to add new books with"""
    #-----------------------------------Form Fields-----------------------------------#
    book_title = StringField('Title of Book', validators=[DataRequired()])
    isbn = StringField('Book ISBN', validators=[DataRequired()])
    author = StringField('Author', validators=[DataRequired()])
    publisher = StringField('Publisher', validators=[DataRequired()])
    is_audio_book = BooleanField("Is it an audiobook?", validators=[])
    num_pages = StringField('Number of Pages', validators=[DataRequired()])
    checkout_length_days = StringField('Max Checkout Length (days)', validators=[DataRequired()])
    late_fee_per_day = StringField('Late Fee (per day)', validators=[DataRequired()])
    book_dewey = StringField('Dewey Decimal Number of Book', validators=[DataRequired()])

    submit = SubmitField('Submit')

    def __init__(self, *args, **kwargs):
        FlaskForm.__init__(self, *args, **kwargs)
        cls = self.__class__ # get reference to cls

        cls.num_pages = StringField('Number of Pages', validators=[DataRequired(), self.validateTypeInt])
        cls.checkout_length_days = StringField('Max Checkout Length (days)', validators=[DataRequired(), self.validateTypeInt])
        cls.late_fee_per_day = StringField('Late Fee (per day)', validators=[DataRequired(), self.validateTypeFloat])
        cls.book_dewey = StringField('Dewey Decimal Number of Book', validators=[DataRequired(), self.validateTypeFloat])

    def validateTypeInt(self, form, field) -> bool:
        print(f"field = {field.name}. data = {field.data}")
        errMsg = f"This field must be a whole number"
        try:
            int_convert = int(field.data)
        except:
            raise ValidationError(message=errMsg) # prints under box

        if isinstance(int_convert, int):
            print("passed validation")
            return True
        else:
            raise ValidationError(message=errMsg) # prints under box

    def validateTypeFloat(self, form, field) -> bool:
        print(f"field = {field.name}. data = {field.data}")
        errMsg = f"This field must be a number. Do not include symbols or letters"
        try:
            float_convert = float(field.data)
        except:
            raise ValidationError(message=errMsg) # prints under box

        if isinstance(float_convert, float):
            print("passed validation")
            return True
        else:
            raise ValidationError(message=errMsg) # prints under box
