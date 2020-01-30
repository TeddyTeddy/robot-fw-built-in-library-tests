# https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#id620
# When variable files are taken into use, they are imported as Python modules and
# all their global attributes that do not start with an underscore (_) are considered to be variables.
# Because variable names are case-insensitive, both lower- and upper-case names are possible,
# but in general, capital letters are recommended for global variables and attributes.
VARIABLE = "An example string"
ANOTHER_VARIABLE = "This is pretty easy!"
INTEGER = 42
# To make creating a list variable or a dictionary variable more explicit,
# it is possible to prefix the variable name with LIST__ or DICT__, respectively:
LIST__STRINGS = ["one", "two", "kolme", "four"]
LIST__NUMBERS = [1, INTEGER, 3.14]
DICT__MAPPING = {"one": 1, "two": 2, "three": 3}
# These prefixes (i.e. LIST__ or DICT__) will not be part of the final variable name,
# but they cause Robot Framework to validate that the value actually is list-like or dictionary-like


# How to use extra arguments passed with variable File
# https://stackoverflow.com/questions/16542814/how-to-use-extra-arguments-passed-with-variable-file-robot-framework
def get_variables(arg1, arg2):
    variables = {"variable #1 in get_variables": arg1,
                 "variable #2 in get variables": arg2,
                 "VARIABLE": VARIABLE,
                 "ANOTHER_VARIABLE": ANOTHER_VARIABLE,
                 "INTEGER": INTEGER,
                 "STRINGS": LIST__STRINGS,
                 "NUMBERS": LIST__NUMBERS,
                 "MAPPING": DICT__MAPPING,
                }
    return variables
