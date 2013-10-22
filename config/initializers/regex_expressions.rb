# regular expressions are stored here for use in all the models
# constants relating to the regex expression sizes are stored here as well

# phone numbers can be 7, 10 or 11 digits long
# validates US formatted numbers, not international numbers
REGEX_PHONE = /^(?:(\d)[ \-\.]?)?(?:\(?(\d{3})\)?[ \-\.])?(\d{3})[ \-\.](\d{4})(?: ?x?(\d+))?$/ 
PHONE_MAX_LENGTH = 20

# allow zipcodes in the format of 12345 or 12345-1234
REGEX_ZIP = /^\d{5}(-\d{4}|)$/
# min legth is set to the 5 digits,  max is set to the database field size limit    
ZIP_MIN_LENGTH = 5
ZIP_MAX_LENGTH = 15

# validates website urls for valid format.
REGEX_WEBSITE = /(http:\/\/|https:\/\/|)(www\.)?([^\.]+)\.(\w{2}|(com|net|org|edu|int|mil|gov|arpa|biz|aero|name|coop|info|pro|museum))$/

# formatted email address validation 
REGEX_EMAIL = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

# for ssn will allow ':', '-' or ' ' to separate the digits
REGEX_SSN = /^\d{3}[ \-\:]\d{2}[ \-\:]\d{4}$/
# ssn_length is set to the limit of the database field size
SSN_LENGTH = 20

# valid ein numbers are 2 digits followed by 7 digits separated by a "-".
# all fed and state forms use a "-" as the separator
REGEX_EIN = /^\d{2}-\d{7}[a-zA-Z]?$/
