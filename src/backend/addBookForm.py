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
    isbn = StringField('Book ISBN (13 digits. no symbols)', validators=[DataRequired()])
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

        cls.isbn = StringField('Book ISBN (13 digits. no symbols)', validators=[DataRequired(), self.validateISBNLen])
        cls.num_pages = StringField('Number of Pages', validators=[DataRequired(), self.validateTypeInt])
        cls.checkout_length_days = StringField('Max Checkout Length (days)', validators=[DataRequired(), self.validateTypeInt])
        cls.late_fee_per_day = StringField('Late Fee (per day)', validators=[DataRequired(), self.validateTypeFloat])
        cls.book_dewey = StringField('Dewey Decimal Number of Book', validators=[DataRequired(), self.validateTypeFloat])

    def validateTypeInt(self, form, field) -> bool:
        # Based on https://dev.mysql.com/doc/refman/8.0/en/integer-types.html
        max_int = 2147483647
        errMsg = f"This field must be a whole number less than {max_int}"
        try:
            int_convert = int(field.data)
        except:
            raise ValidationError(message=errMsg) # prints under box

        if isinstance(int_convert, int) and int_convert <= max_int:
            return True
        else:
            raise ValidationError(message=errMsg) # prints under box

    def validateTypeFloat(self, form, field) -> bool:
        errMsg = f"This field must be a number. Do not include symbols or letters."
        # In this case both dewey and fee per day can be a MINIMUM of 0
        min_float_val = 0

        # can assume unsigned float
        # ref: https://www.w3resource.com/mysql/mysql-data-types.php
        max_float_val = 3.402823466E+38
        try:
            float_convert = float(field.data)
        except:
            raise ValidationError(message=errMsg) # prints under box

        is_valid = True
        is_valid &= isinstance(float_convert, float)
        is_valid &= float_convert >= min_float_val
        is_valid &= float_convert <= max_float_val
        if is_valid:
            return True
        else:
            errMsg += f" The value must be larger than {min_float_val}"
            raise ValidationError(message=errMsg) # prints under box

    def validateISBNLen(self, form, field) -> bool:
        """ISBN is either 10 or 13 digits long. 10 is legacy, but all books now have a 13 digit equivalent"""
        valid_isbn_len = 13
        if len(field.data) != valid_isbn_len:
            errMsg = "ISBN's must be 13 digits long. Please use the Library of Congress"
            errMsg += " (https://catalog.loc.gov/index.html) as a reference source for finding this book's ISBN if unknown."
            raise ValidationError(message=errMsg)
        else:
            return True