# A utility file that contains keywords for built-in-library-test.robot
from robot.api.deco import keyword
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


@keyword
def start_servers(*args):
    for server in args:
        logger.debug(f'{server} is initialized')


@keyword
def initialize_database(database_name):
    logger.debug(f'{database_name} is initialized')


@keyword
def get_integer():
    return -1


@keyword
def raise_type_error_in_python(*args):
    # args is not used here
    raise TypeError("Intentionally failing the keyword by raising this exception")


@keyword
def add_multiple_values(*args):
    # TODO: check if each item passed by built-in-library-test.robot must be an integer
    return sum(args)


@keyword
def title_should_start_with(expected_string):
    selenium_lib = BuiltIn().get_library_instance('SeleniumLibrary')      # uses get_library_instance keyword
    selenium_lib.open_browser(url="https://robotframework.org/#libraries")
    title = selenium_lib.get_title()                       # selenium_lib has a state called title, which is used
    is_starting_with = title.startswith(expected_string)   # within this keyword
    selenium_lib.close_browser()
    return is_starting_with


@keyword
def get_tuple():
    return tuple(get_list())


@keyword
def get_list():
    return ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]


@keyword
def is_string_in_python(s):
    return type(s) == str


@keyword
def is_list_in_python(l):
    return type(l) == list


@keyword
def is_integer_in_python(i):
    return type(i) == int


@keyword
def is_float_in_python(f):
    return type(f) == float


@keyword
def utility_function_one(*args, **kwargs):
    part_1 = 'positional args: ' + str(args)
    part_2 = ' keyworded args: ' + str(kwargs)
    return part_1 + part_2


class StringUtils(object):
    def __init__(self, string):
        self.string = string

    def length(self):
        return len(self.string)


@keyword
def get_string_wrapper(string):
    return StringUtils(string)


class Util(object):
    def __init__(self):
        self.variable = 'value'
        self.length = 5

    def method(self, *args, **kwargs):
        logger.debug(f'args: {args}')
        logger.debug(f'kwargs: {kwargs}')
        part_1 = 'positional args: ' + str(args)
        part_2 = ' keyworded args: ' + str(kwargs)
        return part_1 + part_2

    def __str__(self):
        return 'I am Util object from Python side'


class Util2(object):
    def __init__(self):
        self.variable = 'value'

    def length(self):
        return len(self.variable)

if __name__ == 'Utils':   # if the module is imported by Robot
    utility_object = Util()
    utility_object2 = Util2()
    python_list = [1, 2, 3]
    python_dictionary = {'keyA': 'a', 'keyB': 'b', 'keyC': 'c'}


