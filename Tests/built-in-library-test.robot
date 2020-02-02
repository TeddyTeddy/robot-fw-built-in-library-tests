*** Settings ***
Documentation       Checking out the built-in library's capabilities.
Library             SeleniumLibrary
Library             Utils.py
Library             ../Resources/LibraryOneHavingAConflictingKeyword.py     state text for Library One
Library             ../Resources/LibraryTwoHavingAConflictingKeyword.py     state text for Library Two
Variables           Utils.py
Suite Setup         Suite Setup
Suite Teardown      Suite Teardown


# To run:
# robot  --pythonpath Resources --noncritical failure-expected -d Results/ -v  not-important-setup:'Not Important Setup' -v  important-teardown:'Test Teardown Using "Run Keyword If Test Failed" And "Run Keyword If Test Passed"' -v TestSetup:'Use Pass Execution Setup' -v TestTeardown:'Use Pass Execution Teardown' -v keyword_to_run:'add multiple values' Tests/built-in-library-test.robot  Tests/utilize-global-variable.robot
# OR
# robot  --pythonpath Resources --noncritical failure-expected -d Results/ -v  not-important-setup:'Not Important Setup' -v  important-teardown:'Test Teardown Using "Run Keyword If Test Failed" And "Run Keyword If Test Passed"' -v TestSetup:'Use Pass Execution Setup' -v TestTeardown:'Use Pass Execution Teardown' -v keyword_to_run:'add multiple values' Tests/__init__.robot  Tests/built-in-library-test.robot  Tests/utilize-global-variable.robot Tests/child-suites/child-suite.robot

*** Variables ***
${GLOBAL_VAR}           Global Value
@{LIST}                 Value1      Value2      CONTINUE    Value3
@{MULTI_LINE_LIST}      this     list     is      quite    long     and
...                     items in it could also be long
&{DICTIONARY} =         key1=value1     key2=value2     key3=value3
${VARIABLE}             21

*** Keywords ***
Suite Setup
    Set Log Level     TRACE
    Pass Execution    Suite Setup passed
    Log to Console    Suite Setup, will not be executed

Suite Teardown
    # Pass Execution    Suite Teardown passed   # comment this line out if (x) is to run
    # Log to Console    Suite Teardown, will not be executed
    Run Keyword If All Critical Tests Passed   Log      All Critical Tests Passed   # (x), will be executed
    Run Keyword If Any Critical Tests Failed   Log      Will not be executed
    ${sum} =    Run Keyword If Any Tests Failed     add multiple values     ${1}    ${2}    ${3}


Not Important Setup
    No Operation

Test Teardown Using "Run Keyword If Test Failed" And "Run Keyword If Test Passed"
    Run Keyword If Test Failed      Log     The test the teardown is linked to indeed failed
    Run Keyword If Test Passed      Log     The test the teardown is linked to indeed passed

Use Pass Execution Setup
    Log     Setup executed

Use Pass Execution Teardown
    Log     Teardown executed

Log "Key: Value" Pairs
    [Arguments]  ${variables_dict}
    FOR     ${key}  IN  @{variables_dict}
        Log Many   ${key}   ${variables_dict}[${key}]
    END

Find Index (version one)
    [Arguments]     ${element_to_look_for}   @{items}
    ${index} =      Set Variable   ${0}
    FOR    ${item}  IN  @{items}
        Run Keyword If  $item == $element_to_look_for   Return From Keyword    ${index}     ${item}
        ${index} =      Evaluate   $index + 1
    END
    [Return]    Not Found     ${element_to_look_for}  # Also "Return From Keyword" would work here

Find Index (version two)
    [Arguments]     ${element_to_look_for}   @{items}
    ${index} =      Set Variable   ${0}
    FOR    ${item}  IN  @{items}
        Return From Keyword If  $item == $element_to_look_for        ${index}     ${item}
        ${index} =      Evaluate   $index + 1
    END
    [Return]    Not Found     ${element_to_look_for}  # Also "Return From Keyword" would work here

Keyword That Uses "Run Keyword And Return If"
    [Documentation]         Run Keyword And Return If 	condition, name, *args
    ...                     Runs the specified keyword and returns from the enclosing user keyword
    Run Keyword And Return If 	${True} 	add multiple values   ${1}   ${1}   ${1}

Keyword That Uses "Run Keyword If" And "Run Keyword And Return" Keywords
    [Documentation]         Run Keyword And Return   name, *args
    ...                     Runs the specified keyword and returns from the enclosing user keyword
    Run Keyword If 	    ${True} 	Run Keyword And Return 	add multiple values   ${1}   ${1}   ${1}

Linux Keyword
    [return]  Linux

Jython Keyword
    [return]  Jython

Windows Keyword
    [return]  Windows

Teardown That Uses "Run Keyword If Timeout Occurred"
    Run Keyword If Timeout Occurred     Log       In 'Use "Run Keyword If Timeout Occurred"' test, timeout occurred

This Keyword Must Access ListX
    [Documentation]     note that this keyword has no [Arguments] defined
    Variable Should Exist   ${ListX}
    @{expected} =   Create List     item1      item2
    Should Be Equal     ${expected}     ${listX}

(Test 1/3) Use "Set Test Message" - Teardown
    Log         ${TEST MESSAGE}

(Test 2/3) Use "Set Test Message" - Teardown Overriding The Failure Message
    Log                 ${TEST MESSAGE}
    Set Test Message    This overrides the failure message
    Log                 ${TEST MESSAGE}

Keyword Creating A Test Variable
    Set Test Variable   ${test-scoped-var}   test scoped

Keyword Logging The Test Variable
    Log     ${test-scoped-var}

*** Test Cases ***
Use "Call Method" : Calling A Particular Object Method From Python
    ${result} =     Call Method     ${utility_object}    method     pos_arg1    pos_arg2     key1=value1   key2=value2
    Should Be Equal     positional args: ('pos_arg1', 'pos_arg2') keyworded args: {'key1': 'value1', 'key2': 'value2'}      ${result}

Use "Catenate"
    ${str1} =        Catenate        Hello       World
    Should Be Equal As Strings     ${str1}    Hello World
    ${str1}         Catenate        SEPARATOR=---   Hello       World
    Should Be Equal As Strings     ${str1}    Hello---World

Use "Continue For Loop" and "Run Keyword If"
    FOR  ${var}  IN   @{LIST}
        Run Keyword If  '${var}' == 'CONTINUE'    Continue For Loop
        Log   ${var}
    END

Use "Continue For Loop If"
    FOR  ${var}  IN   @{LIST}
        Continue For Loop If  '${var}' == 'CONTINUE'
        Log   ${var}
    END

Use "Convert To Binary"
    [Documentation]     "Convert To Binary" keyword accepts a STRING as its first argument.
    ...                 The string first argument is first passed to "Convert To Integer"
    ...                 keyword and the result is then converted to a binary number represented as a string
    ...                 If you passed an INTEGER as its first argument, the test will fail

    ${variable} =       Set Variable    10
    Should Be Equal     ${variable}     10   # 10 as a string!

    ${binary_string} =  Convert To Binary   ${variable}     base=10
    Should Be Equal     ${binary_string}      1010

    ${variable} =       Set Variable    F
    ${binary_string} =  Convert To Binary   ${variable}     base=16     prefix=0x     length=8
    Should Be Equal     ${binary_string}      0x00001111

    ${binary_string} =  Convert To Binary 	-2 	prefix=B 	length=4 	# Result is -B0010
    Should Be Equal     ${binary_string}     -B0010

Use "Convert To Boolean"
    ${bool} =   Convert To Boolean  True
    Should Be Equal     ${bool}     ${True}

    ${bool} =   Convert To Boolean  False
    Should Be Equal     ${bool}     ${False}

    ${empty} =          Create Dictionary
    ${bool} =   Convert To Boolean  ${empty}
    Should Be Equal     ${bool}     ${False}

    ${non-empty} =          Create Dictionary   key=value
    ${bool} =   Convert To Boolean  ${non-empty}
    Should Be Equal     ${bool}     ${True}

    ${empty} =          Create List
    ${bool} =   Convert To Boolean  ${empty}
    Should Be Equal     ${bool}     ${False}

    ${non-empty} =          Create List   1     2      3
    ${bool} =   Convert To Boolean  ${non-empty}
    Should Be Equal     ${bool}     ${True}


Use "Convert To Integer"
    [Documentation]     Convert To Integer 	item, base=None
    ...                 Converts the given STRING item in a given base to an integer in base 10
    ...                 The resulting integer is indeed recognized by Python as an integer type

    ${variable} =       Convert To Integer  10   # the given item is taken as a string in base 10
    Should Be Equal     ${variable}     ${10}
    ${isInteger} =      is integer in python    ${variable}
    Should Be Equal     ${isInteger}        ${True}

    ${variable} = 	        Convert To Integer 	item=FF AA 	base=16 	# Result is 65450
    ${expected_value} =     Convert To Integer  item=65450   # string 65450 with base 10 is converted to integer
    Should Be Equal         ${variable}     ${expected_value}

Use "Convert To Bytes"
    [Documentation]  https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Convert%20To%20Bytes
    ...              The description is unclear. To be reviewed
    [Tags]           not-understood
    Fail    Should Be Implemented

Use "Convert To Hex"
    [Documentation]  Convert To Hex 	item, base=None, prefix=None, length=None, lowercase=False
    ...              Converts the given item to a hexadecimal string.
    ...              The item, with an optional base, is first converted to an integer using "Convert To Integer" internally.
    ...              After that it is converted to a hexadecimal number (base 16) represented as a string such as FF0A.
    ...              The outcome of "Convert To Hex" is a (hexadecimal) string, which is recognized as string in Python

    ${hex_value} = 	    Convert To Hex 	255   base=10  prefix=0x		# Result is 0xFF
    ${isString} =       is string in python    ${hex_value}
    Should Be True      ${isString}                     # The outcome of "Convert To Hex" is a (hexadecimal) string in Python
    Should Be True      ${hex_value}==${0xFF}


    ${result} = 	Convert To Hex 	-10 	prefix=0x 	length=2 	# Result is -0x0A
    Should Be True      ${result}==-${0x0A}     # i.e. -0x0A==-10

    ${result} = 	Convert To Hex 	255 	prefix=X 	lowercase=yes 	# Result is Xff as a string
    Should Be True      $result=='Xff'

Use "Convert To Integer (in base 10)"
    [Documentation]     Convert To Integer 	item, base=None
    ...                 Converts the given item to an integer number in base 10

    # If the given item is a string, it is by default expected to be an integer in base 10
    ${result} = 	Convert To Integer 	100 		# Result is 100
    ${isInt} =      is integer in python  ${result}
    Should Be True      ${isInt}     ${True}

    # There are two ways to convert from other bases:
    # Way 1: Give base explicitly to the keyword as base argument
    ${result} = 	Convert To Integer 	FF AA 	base=16 	# Result is 65450
    ${result} = 	Convert To Integer 	100 	base=8 	    # Result is 64
    ${result} = 	Convert To Integer 	-100 	base=2 	    # Result is -4
    # Way 2: Prefix the given string with the base so that 0b means binary (base 2), 0o means octal (base 8), and 0x means hex (base 16).
    # The prefix is considered only when base argument is not given and may itself be prefixed with a plus or minus sign.
    ${result} = 	Convert To Integer 	0b100 		# Result is 4
    ${result} = 	Convert To Integer 	-0x100 		# Result is -256

Use "Convert To (Floating Point) Number"
    [Documentation]    Convert To Number 	item, precision=None
    ...                item is a floating point string
    ...                Converts the given item to a floating point number, which is indeed recognized as float in Python
    [Tags]             not-understood
    ${variable} =      Convert To Number   42.512783
    ${isFloat} =       is float in python   ${variable}
    Should Be Equal    ${isFloat}           ${True}    # recognized as float in python

    # If the optional precision is positive or zero, the returned number is rounded to that number of decimal digits
    ${variable} =      Convert To Number   42.512783  precision=4
    Should Be Equal    ${variable}         ${42.5128}
    ${variable} =      Convert To Number   42.512783  precision=0
    Should Be Equal    ${variable}         ${43}

    # Negative precision means that the number is rounded to the closest multiple of (10 to the power of the absolute precision)
    ${variable} =      Convert To Number   42.512783  precision=-1
    Should Be Equal    ${variable}         ${40.0}

    Comment     ??? If you want to avoid possible problems with floating point numbers, you can implement custom keywords using
    Comment     Python's decimal or fractions modules.
    Fail    Should Be Implemented

Use "Convert To Octal"
    [Documentation]  Convert To Octal 	item, base=None, prefix=None, length=None
    ...              Converts the given item to an octal string
    ${result} = 	Convert To Octal 	10 			# Result is 12
    ${isString} =   is string in python  ${result}
    Should Be Equal    ${isString}      ${True}
    Should Be Equal   ${result}   12

    ${result} = 	Convert To Octal 	-F 	base=16 	prefix=0 	# Result is -017
    Should Be Equal     ${result}       -017

    ${result} = 	Convert To Octal 	16 	prefix=oct 	length=4 	# Result is oct0020
    Should Be Equal     ${result}       oct0020

Use "Convert To String"
    [Documentation]     Totally unclear..
    [Tags]              not-understood
    Fail        Should Be Implemented


Use "Create Dictionary"
    &{dict} = 	Create Dictionary 	key=value 	foo=bar 			# key=value syntax
    Should Be True 	${dict} == {'key': 'value', 'foo': 'bar'}

    &{dict2} = 	Create Dictionary 	key 	value 	foo 	bar 	# separate key and value
    Should Be Equal 	${dict} 	${dict2}

    &{dict} = 	Create Dictionary 	${1}=${2} 	&{dict} 	foo=new 		# using variables
    Should Be True 	    ${dict} == {1: 2, 'key': 'value', 'foo': 'new'}
    Should Be Equal 	${dict.key} 	value 				# dot-access

Use "Create List"
    #  The returned list can be assigned both to ${scalar} and @{list} variables
    @{list} =   Create List     a   b   c
    Should Be True      ${list} == ['a', 'b', 'c']
    ${isList} =         is list in python   ${list}
    Should Be True      ${isList}
    ${list} = 	Create List 	${1} 	${2} 	${3}   # items are called "Number Variables" in Robot and they are integers
    Should Be True      $list == [1, 2, 3]
    ${isInteger} =      is integer in python  ${list}[1]
    Should Be True      ${isInteger}

Use "Evaluate"
    ${pi} =         Convert To Number        3.14159265359  # not a string, but a float
    # Variables used like ${pi} are replaced in the expression before evaluation
    ${result} =     Evaluate  0 < ${pi} < 10         # pi's string representation is placed in to the expression
    Should Be True  ${result}

    # Variables are also available in the evaluation namespace and can be accessed using special syntax $pi
    ${result} =     Evaluate  0 < $pi < 10          # Using variable pi itself, not string representation
    Should Be True  ${result}

    # modules argument can be used to specify a comma separated list of Python modules to be imported and
    # added to the evaluation namespace.
    ${random_int} = 	Evaluate 	random.randint(0, 100) 	modules=random, sys
    ${isInteger}=       is integer in python  ${random_int}
    Should Be True      ${isInteger}

    # namespace argument can be used to pass a custom evaluation namespace as a dictionary.
    # Possible modules are added to this namespace.
    ${ns} = 	    Create Dictionary 	x=${4} 	y=${2}      # values are called "Number Variables" in Robot and they are integers
    ${result} = 	Evaluate 	x*10 + y 	namespace=${ns}     modules=random, sys
    ${isInteger}=       is integer in python    ${result}
    Should Be True      ${isInteger}
    Should Be Equal     ${42}       ${result}

Use "Exit For Loop"
    @{list} =   Create List     a   b   c   EXIT  d  e
    # Below FOR loop will log only a  b  c, but nothing else
    FOR   ${item}  IN   @{list}
        Run Keyword If      $item == 'EXIT'     Exit For Loop
        Log     ${item}
    END

Use "Fail"
    [Documentation]     Fails the test with the given message and optionally alters its tags ?
    [Tags]              tag-to-be-removed   failure-expected
    Fail                This test case must fail bcoz it uses Fail keyword    -tag-to-be-removed

#Use "Fatal Error"
#    [Documentation]     Fatal Error 	msg=None
#    ...                 The test or suite where this keyword is used fails with the provided message,
#    ...                 and subsequent tests fail with a canned message
#    Fatal Error 	    msg=Fatal Error. The rest of the tests below will not be executed

Use "Get Count"
    [Documentation]     Get Count 	item1, item2
    ...                 Returns and logs how many times item2 is found from item1
    ...                 This keyword works with Python strings and lists and
    ...                 all objects that either have count method or can be converted to Python lists.

    # with Python strings
    ${item1} =          Set Variable   Lorem Ipsum Lorem Ipsum Lorem
    ${item2} =          Set Variable   Ipsum
    ${count} =          Get Count      item1=${item1}    item2=${item2}
    Should Be Equal     ${count}       ${2}

    # with Python lists
    @{list} =           get list      # ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${count} =          Get Count     item1=${list}     item2=a
    Should Be Equal     ${count}       ${2}
    ${count} =          Get Count     item1=${list}     item2=${1}
    Should Be Equal     ${count}       ${3}

    # with any object that can be converted to Python lists
    ${tuple} =          get tuple      # ('a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1)
    ${count} =          Get Count     item1=${tuple}     item2=a
    Should Be Equal     ${count}       ${2}
    ${count} =          Get Count     item1=${tuple}     item2=${1}
    Should Be Equal     ${count}       ${3}

Use "Get Length"
    [Documentation]     Get Length 	item
    ...                 Returns and logs the length of the given item as an integer
    [Tags]              failure-expected

    # The keyword first tries to get the length with the Python function len, which calls the item's __len__ method internally
    # note that len(any_list) will return the length value
    @{list} =           get list      # ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    ${length} =         Get Length      item=${list}
    Should Be Equal     ${length}       ${10}

    # If that fails, the keyword tries to call the item's possible length and size methods directly
    ${string_wrapper} =   get_string_wrapper  I am a string of length 26
    ${length} =         Get Length      item=${string_wrapper}
    Should Be Equal     ${length}       ${26}

    # The final attempt is trying to get the value of the item's 'length' attribute
    ${length} =         Get Length      item=${utility_object}
    Should Be Equal     ${length}       ${5}

     # If all the above attempts are unsuccessful, the keyword "Get Length" fails.
     ${integer} =       Set Variable            ${3}
     ${length} =        Get Length      item=${integer}     # Expected, Error: Could not get length of '3'.


Use "Get Library Instance" In Python
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Get%20Library%20Instance
    [Tags]              not-understood

    &{all robot libs} =     Get library instance 	all=True
    FOR     ${item}  IN     @{all robot libs}
        Log Many        ${item}     ${all robot libs}[${item}]
    END

    ${is_starting} =        title should start with     Title does not start with me   # Refer to Utils.py
    Should Be False         ${is_starting}

    ${is_starting} =        title should start with     Robot                          # Refer to Utils.py
    Should Be True          ${is_starting}

    # The usage of this keyword in python as stated by an example in the given link is unclear
    Comment         What are usage scenarios of "Get Library Instance" in a Python module?
    Comment         What are usage scenarios of "Get Library Instance" in a Robot test case?
    Fail            Test needs to be implemented

Use "Get Time"
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Get%20Time
    ...                 Get Time 	format=timestamp, time_=NOW
    ...                 Returns the given time in the requested format.
    ...                 NOTE: DateTime library contains much more flexible keywords for getting the current date and
    ...                 time and for date and time handling in general.
    ...                 How time is returned is determined based on the given format string as follows.
    ...                 Note that all checks are case-insensitive.

    # no format provided, gets the local time in YYYY-MM-DD hh:mm:ss  format
    ${time} = 	    Get Time

    # If format contains the word epoch, the time is returned in seconds after the UNIX epoch (1970-01-01 00:00:00 UTC).
    # The return value is always an integer.
    ${time} = 	    Get Time        format=epoch

    # If format contains any of the words year, month, day, hour, min, or sec, only the selected parts are returned.
    # The order of the returned parts is always the one in the previous sentence and the order of words in format is
    # not significant. The parts are returned as zero-padded strings (e.g. May -> 05).
    ${month}   ${min} = 	Get Time   min month   # note that the order is mingled but the keyword returns ${month}   ${min} in the given order

    # By default this keyword returns the current local time, but that can be altered using 'time'
    # argument as explained below. Note that all checks involving strings are case-insensitive.
    # 1) If time is a number, or a string that can be converted to a number, it is interpreted as seconds since the UNIX epoch.
    # This documentation was originally written about 1177654467 seconds after the epoch.
    ${time} = 	Get Time 		1177654467 	    # Time given as epoch seconds
    # If time is a timestamp, that time will be used. Valid timestamp formats are YYYY-MM-DD hh:mm:ss and YYYYMMDD hhmmss
    ${secs} = 	Get Time 	    sec 	2007-04-27 09:14:27 	# Time given as a timestamp
    # If time is equal to NOW (default), the current local time is used.
    ${year} = 	Get Time 	year 	NOW 	    # The local time of execution
    # If time is equal to UTC, the current time in UTC is used.
    ${time_in_UTC} =        Get Time     UTC
    # If time is in the format like NOW - 1 day or UTC + 1 hour 30 min, the current local/UTC time plus/minus
    # the time specified with the time string is used
    # TODO: https://stackoverflow.com/questions/59801106/time-get-time-time-now-1h-2min-3s-1h-2min-3s-added-to-the-local-time
    ${time} = 	Get Time 	time_=NOW + 1h 2min 3s 	# 1h 2min 3s added to the local time

    @{utc} = 	Get Time 	format=hour min sec 	time_=UTC 	# The UTC time of execution

    ${year} 	${seconds} = 	Get Time 	format=seconds and year

Use "Get Variable Value"
    [Documentation]         Get Variable Value 	name, default=None
    ...                     Returns variable value or default if the variable does not exist.
    ${a} =  Set Variable     ${5}
    ${x} =  Get Variable Value  ${a}  default value for x
    Should Be Equal     ${x}    ${5}

    ${x} =  Get Variable Value  ${does not exist}  default value for x
    Should Be Equal     ${x}    default value for x

Use "Get Variables"
    [Documentation]     Get Variables 	no_decoration=False
    ...                 Returns a dictionary containing all variables in the current scope.
    ...                 Variables are returned as a special dictionary that allows accessing variables in space, case,
    ...                 and underscore insensitive manner similarly as accessing variables in the test data.
    ...                 This dictionary supports all same operations as normal Python dictionaries and, for example,
    ...                 Robot's Collections library can be used to access or modify it.
    ...                 Modifying the returned dictionary has no effect on the variables available in the current scope.
    ${a} =      Set Variable    ${5}
    ${variables_dict} =        Get Variables
    Log "Key: Value" Pairs     ${variables_dict}

    # ${variables_dict} is a dictionary, which can be modified by the Robot's Collection module
    Import Library      Collections
    Dictionary Should Contain Key    ${variables_dict}   \${a}
    # Modifying the returned dictionary (i.e. ${variables_dict} ) has no effect on the variables available in the current scope.
    Set To Dictionary 	${variables_dict} 	\${name} 	value
    Variable Should Not Exist       \${name}    #  Fails if the given variable exists within the current scope.

    # By default variables are returned with ${}, @{} or &{} decoration based on variable types.
    # Giving a true value (see Boolean arguments) to the optional argument no_decoration will
    # return the variables without the decoration.
    ${variables_dict} =        Get Variables    no_decoration=True
    Dictionary Should Contain Key   ${variables_dict}   a

(Test 1/3) Use "Import Library" To Load LibraryWithState.py
    [Documentation]     https://stackoverflow.com/questions/59824272/robot-framework-builtin-module-import-library-keyword-how-to-pass-argume
    ...                 This very Test 1/3  imports dynamically LibraryWithState.py, which is made availabe to the whole test suite
    ...                 initializing a LibraryWithState class instance. This class instance is initialized
    ...                 the same way every time before subsequent test cases (i.e. Test 2/3 and Test 3/3) are called
    Import Library      LibraryWithState.py       CURRENT STATE       key1=value1     key2=value2

(Test 2/3) Change the state in the current LibraryWithState Instance
    [Documentation]     Note that in Test 2/3 and in Test 3/3, the LibraryWithState instance is re-initialized
    ...                 for each test case.
    ${state} =      get state   # from instance of the class 'LibraryWithState', returning the string 'CURRENT STATE'
    Should Be True  $state=='CURRENT STATE'
    set state       Test 2/3    # from instance of the class 'LibraryWithState', setting the string 'Test 2/3' to LibraryWithState instance
    ${state} =      get state   # from instance of the class 'LibraryWithState', returning the string 'Test 2/3'
    Should Be True  $state=='Test 2/3'

(Test 3/3) Change the state in the current LibraryWithState Instance
    [Documentation]     Note that in Test 2/3 and in Test 3/3, the LibraryWithState instance is re-initialized
    ...                 for each test case.
    ${state} =      get state   # from instance of the class 'LibraryWithState', returning the string 'CURRENT STATE'
    Should Be True  $state=='CURRENT STATE'
    set state       Test 3/3    # from instance of the class 'LibraryWithState', setting the string 'Test 3/3' to LibraryWithState instance
    ${state} =      get state   # from instance of the class 'LibraryWithState', returning the string 'Test 3/3'
    Should Be True  $state=='Test 3/3'

(Test 1/2) Use "Import Resource" To Load "amazon.resource" file
    [Documentation]     Resources imported with this keyword are set into the test suite scope similarly
    ...                 when importing them in the Setting table using the Resource setting.
    ...                 The user keywords and variables defined in a resource file are available in the
    ...                 file that takes that resource file into use.
    Import Resource     amazon.resource

(Test 2/2) Use The Keywords In File "amazon.resource"
    [Documentation]     Refer to the test above:  "(Test 1/2) Use "Import Resource" To Load "amazon.resource" file
    Open Home Page          # this keyword is imported from  /Resources/amazon.resource
    Search For A Product    # this keyword is imported from  /Resources/amazon.resource
    Variable Should Exist     ${URL}      # this variable is imported from /Resources/amazon.resource

(Test 1/3) Use "Import Variables"
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Import%20Variables
    ...                 Variables imported with this keyword are set into the test suite scope similarly
    ...                 when importing them in the Setting table using the Variables setting
    ...                 The given path must be absolute or found from search path.
    ...                 Forward slashes can be used as path separator regardless the operating system.
    # arg1 and arg2 are passed to get_variables() method in Tests/variables.py
    Import Variables    /home/hakan/Python/Robot/built-in-library/Tests/variables.py    first   second


(Test 2/3) After Using The Keyword "Import Variables", Referring To Imported Variables
    Log        ${MAPPING}  # a dictionary from Tests/variables.py
    Log        ${NUMBERS}  # a list from Tests/variables.py

(Test 3/3) Reading The Variables Initialized By Passing The Arguments "first second" To "Import Variables" Keyword
    [Documentation]     Refer to (Test 1/3) Use "Import Variables"
    ...
    Should Be Equal     ${variable #1 in get_variables}     first
    Should Be Equal     ${variable #2 in get_variables}     second

Use "Keyword Should Exist"
    [Documentation]         Fails unless the given keyword exists in the current scope.
    ...                     Note that in (Test 1/2) Use "Import Resource" To Load amazon.resource file, we have used the following statement:
    ...                     Import Resource     /home/hakan/Python/Robot/built-in-library/Resources/amazon.resource
    Keyword Should Exist    Search For A Product   # this keyword is imported from the resource file "Resources/amazon.resource"

Use "Length Should Be"
    ${lst} =        Create List   ${1}   ${2}   ${3}
    Length Should Be    ${lst}      ${3}

Use "Log To Console"
    Log To Console      Check if this message is written to the console correctly

Use "Log Variables"
    Log Variables

(Test 1/2) Use "Pass Execution"
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Pass%20Execution
    ...                 When used in a test outside setup or teardown, passes that particular test case.
    ...                 Possible test and keyword teardowns are executed.
    [Setup]     ${TestSetup}
    ${value} =      Set Variable    ${-10}
    Run Keyword If 	${value} < 0 	Pass Execution 	message=Negative values are cool.
    Log     This message is not logged since "Pass Execution" keyword is called in the previous line
    [Teardown]     ${TestTeardown}  # will be executed even though "Pass Execution" got called

(Test 2/2) Use "Pass Execution"
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Pass%20Execution
    ...                 This keyword can be used anywhere in the test data, but the place where used affects the behavior:
    ...                 When used in any setup or teardown (suite, test or keyword), passes that setup or teardown.
    ...                 Possible keyword teardowns of the started keywords are executed. Does not affect execution or statuses otherwise.
    Pass Execution     (Test 2/2) Use "Pass Execution" passed with Pass Execution
    Log    this will not be executed due to "Pass Execution" keyword being executed in the line above

Use "Pass Execution If"
    [Setup]     ${TestSetup}
    @{lst} =            Create List   ${1}  ${2}  Expected  ${3}  ${4}
    FOR 	${item} 	IN 	@{lst}
	    Pass Execution If 	'${item}' == 'Expected' 	Correct value was found
	    Log 	${item}
	END
	[Teardown]     ${TestTeardown}  # will be executed even if the condition in "Pass Execution If" is true

Use "Regexp Escape"
    [Documentation]     Totally unclear
    [Tags]              not-understood
    Fail    Test needs to be implemented

Use "Reload Library"
    [Documentation]     https://stackoverflow.com/questions/60025662/robot-fw-builtin-library-reload-library-keyword-how-to-use-reload-libra
    [Tags]              not-understood
    Fail    implement this once ticket is answered

Use "Remove Tags"
    [Documentation]     When this test case got executed, it will have 2 tags: dynamic-tag-1 + keep-me-tag
    [Tags]          remove-me-tag-1     remove-me-tag-2     keep-me-tag
    Set Tags        dynamic-tag-1       dynamic-tag-2
    Remove Tags     remove-me-tag-?     [dxyz]ynamic-tag-2

Use "Repeat Keyword"
    [Documentation]     repeat, name, *args
    ...                 Executes the specified keyword (i.e. name) multiple times.
    Repeat Keyword      3x      Log Many        Log Me 1        Log Me 2

Use "Replace Variables"
    [Documentation]     Replace Variables  text
    ...                 Replaces variables in the given text with their current values as strings
    ...                 In other words it returns the string representation of each and every variable
    ...                 in text argument
    [Tags]              failure-expected

    &{d} =    Create Dictionary     key1=value1     key2=value2
    @{l} =    Create List           ${1}    ${2}   ${3}

    # If the given text contains only a single variable, its value is returned as-is and it can be any object.
    ${l_rereturned} =   Replace Variables    ${l}
    Should Be Equal     ${l}     ${l_rereturned}

    # Otherwise this keyword always returns a string
    ${variable_values_in_string_format_seperated_by_a_space_character} =  Replace Variables    ${d} ${l}
    Should Be Equal  ${variable_values_in_string_format_seperated_by_a_space_character}   {'key1': 'value1', 'key2': 'value2'} [1, 2, 3]

    # Otherwise this keyword always returns a string
    ${variable_values_in_string_format_seperated_by_a_plus_character} =  Replace Variables    ${d}+${l}
    Should Be Equal  ${variable_values_in_string_format_seperated_by_a_plus_character}   {'key1': 'value1', 'key2': 'value2'}+[1, 2, 3]

    Comment     If the text contains undefined variables, "Replace Variables" keyword fails
    ${will_fail} =   Replace Variables    ${l} ${non existing variable}

Use "Return From Keyword"
    @{l} =    Create List           ${1}    ${2}   ${3}

    # ${2}: element to look for
    # @{l}: from where to look for the items
    ${found_index}  ${element_to_look_for} =  Find Index (version one)   ${2}   @{l}  # uses "Return From Keyword"
    Should Be True  $found_index==1
    Should Be True  $element_to_look_for==2

    # ${2}: element to look for
    # @{l}: from where to look for the items
    ${found_index}  ${element_to_look_for} =  Find Index (version one)  non-existing-value   @{l}  # uses "Return From Keyword"
    Should Be True  $found_index=='Not Found'
    Should Be True  $element_to_look_for=='non-existing-value'

Use "Return From Keyword If"
    @{l} =    Create List           ${1}    ${2}   ${3}

    # ${2}: element to look for
    # @{l}: from where to look for the items
    ${found_index}  ${element_to_look_for} =  Find Index (version two)   ${2}   @{l}  # uses "Return From Keyword If"
    Should Be True  $found_index==1
    Should Be True  $element_to_look_for==2

    # ${2}: element to look for
    # @{l}: from where to look for the items
    ${found_index}  ${element_to_look_for} =  Find Index (version two)   non-existing-value   @{l}  # uses "Return From Keyword If"
    Should Be True  $found_index=='Not Found'
    Should Be True  $element_to_look_for=='non-existing-value'

Use "Run Keyword" With A Provided Keyword From Command Line
    [Documentation]     Because the name of the keyword to execute is given as an argument, it can be a variable
    ...                 and thus set dynamically, e.g. from a return value of another keyword or from the command line.
    ${result} =     Run Keyword     ${keyword_to_run}   ${1}     ${1}    ${1}  # from Utils.py
    Should Be True   $result == 3

Use "Run Keyword And Continue On Failure"
    [Tags]              failure-expected
    ${will_be_initilized_with_None} =  Run Keyword And Continue On Failure     raise type error in python   ${1}   ${2}   ${3}
    Log     This line is executed even though the previous line has failed

Use "Run Keyword And Expect Error"
    [Documentation]         https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Return%20From%20Keyword
    ...                     Run Keyword And Expect Error 	expected_error, name, *args
    ...                     Runs the keyword and checks that the expected error occurred.
    ...                     The keyword to execute and its arguments are specified using name and *args
    ...                     exactly like with Run Keyword.
    [Tags]                  failure-expected

    # The expected error must be given in the same format as in Robot Framework reports
    # If the expected error occurs, the error message is returned and it can be further processed or tested if needed
    ${will_be_initilized_with_the_error_message} =  Run Keyword And Expect Error     EQUALS:TypeError: Intentionally failing the keyword by raising this exception     raise type error in python   ${1}   ${2}   ${3}
    ${will_be_initilized_with_the_error_message} =  Run Keyword And Expect Error     STARTS:TypeError     raise type error in python   ${1}   ${2}   ${3}

    # If there is no error, or the error does not match the expected error, this keyword fails.
    Comment     The following failure is expected
    ${result} =     Run Keyword And Expect Error     STARTS:TypeError   ${keyword_to_run}   ${1}     ${1}      ${1}  # from Utils.py, will NOT raise any errors
    Log     This line is not executed bcoz the previous line has failed

Use "Run Keyword And Ignore Error"
    [Documentation]        Run Keyword And Ignore Error 	name, *args
    ...                    This keyword returns two values, so that the first is either string PASS or FAIL,
    ...                    depending on the status of the executed keyword. The second value is either the return value
    ...                    of the keyword or the received error message.
    ${execution_status}  ${result} =   Run Keyword And Ignore Error    raise type error in python   ${1}   ${2}   ${3}
    Should Be True      $execution_status == 'FAIL'
    Should Be True      $result == 'TypeError: Intentionally failing the keyword by raising this exception'

    ${execution_status}  ${result} =   Run Keyword And Ignore Error    add multiple values   ${1}   ${1}   ${1}
    Should Be True      $execution_status == 'PASS'
    Should Be True      $result == 3

Use "Run Keyword And Return If"
    [Documentation]         Run Keyword And Return If 	condition, name, *args
    ...                     If the condition is True, Runs the specified keyword (designated by name) and returns from
    ...                     the enclosing user keyword
    ${result_1} =       Keyword That Uses "Run Keyword And Return If"
    ${result_2} =       Keyword That Uses "Run Keyword If" And "Run Keyword And Return" Keywords
    Should Be True      $result_1 == $result_2

Use "Run Keyword And Return Status" (Along With "Run Keyword If")
    [Documentation]         Run Keyword And Return Status 	name, *args
    ...                     Runs the given keyword with given arguments and returns the status as a Boolean value.
    ...                     Returns Boolean True if the keyword that is executed succeeds and False if it fails.
    ${passed} =     Run Keyword And Return Status   raise type error in python   ${1}   ${2}   ${3}
    Run Keyword If      ${passed}     Log    This logging part will not be executed
    Run Keyword If      not $passed     Log     This logging part will be executed

    ${passed} =     Run Keyword And Return Status   add multiple values   ${1}   ${1}   ${1}
    Run Keyword If      ${passed}       Log     This logging part will be executed
    Run Keyword If      not $passed     Log     This logging part will not be executed

Use "Run Keyword If"
    [Documentation]         Run Keyword If 	condition, name, *args
    ...                     If condition is true, runs the given keyword (designated by 'name' argument) with
    ...                     the given args


    ${isPassed}       ${result} =   Run Keyword And Ignore Error 	add multiple values   ${1}   ${1}   ${1}
    ${condition} =    Evaluate      $isPassed=='PASS' and $result==3
    # Example, a simple if/else construct via the use of "Run Keyword If"
    Run Keyword If  $condition      Log   If part, will be printed
    Run Keyword Unless  $condition     Log      Else part, will not be printed
    # Usage of ELSE; re-writing the previous if/else construct
    Run Keyword If  $condition      Log     If part, will be printed        ELSE    Log     Else part, will not be printed

    # The return value of this keyword is the return value of the actually executed keyword or
    # Python None if no keyword was execute
    ${should be None} =   Run Keyword If    ${True}       Log   Log does not return anything; None should be returned
    Should Be Equal     ${should be None}       ${None}
    ${should be three} =    Run Keyword If    ${True}     add multiple values   ${1}   ${1}   ${1}
    Should Be Equal     ${should be three}    ${3}

    # it is recommended to use ELSE and/or ELSE IF branches to conditionally assign return values from keyword to variables
    ${conditionally assigned variable} =    Run Keyword If      ${False}     add multiple values   ${1}   ${1}   ${1}
    ...                                     ELSE IF             ${False}     add multiple values   ${2}   ${2}   ${2}
    ...                                     ELSE IF             ${True}      add multiple values   ${3}   ${3}   ${3}
    ...                                     ELSE                get integer    # returns -1
    Should Be Equal     ${conditionally assigned variable}      ${9}

    # Python's os and sys modules are automatically imported when evaluating the condition
    # Attributes they contain can thus be used in the condition:
    ${platform} =       Run Keyword If 	os.sep == '/' 	Linux Keyword
    ... 	            ELSE IF 	sys.platform.startswith('java') 	Jython Keyword
    ... 	            ELSE 	    Windows Keyword
    Should Be True      $platform == 'Linux'

Use "Run Keyword If Test Failed"
    [Documentation]     This test case is intentionally designed to fail, refer to its teardown
    [Tags]              failure-expected
    [Setup]             ${not-important-setup}
    Fail                This test case is intentionally designed to fail, refer to its teardown
    [Teardown]          ${important-teardown}

Use "Run Keyword If Test Passed"
    [Documentation]     This test case does nothing and just passes, refer to its teardown
    [Setup]             ${not-important-setup}
    No Operation
    [Teardown]          ${important-teardown}

Use "Run Keyword If Timeout Occurred"
    [Documentation]     Run Keyword If Timeout Occurred 	name, *args
    ...                 Runs the given keyword if either a test or a keyword timeout has occurred.
    ...                 This keyword can only be used in a test teardown. Trying to use it anywhere else results in an error.
    ...                 Otherwise, this keyword works exactly like "Run Keyword", see its documentation for more details.
    [Tags]              failure-expected
    [Timeout]           1 milliseconds   # intentionally setting a very short timeout
    # the following statements will fail the test --> with timeout
    ${no result} = 	    Wait Until Keyword Succeeds 	3x 	100ms 	raise type error in python      a       b       c
    [Teardown]           Teardown That Uses "Run Keyword If Timeout Occurred"

Use "Run Keyword Unless"
    [Documentation]     Run Keyword Unless 	condition, name, *args
    ...                 Runs the given keyword with the given arguments if condition is false
    ${expect_six} =   Run Keyword Unless   ${False}     add multiple values     ${1}   ${2}   ${3}
    Should Be True  $expect_six == 6

    ${expect_None} =   Run Keyword Unless   ${True}     add multiple values     ${1}   ${2}   ${3}  # the provided keyword will not run
    Should Be True  $expect_None is None

Use "Run Keywords"
    [Documentation]     Run Keywords 	*keywords
    ...                 Keywords can also be run with arguments using upper case AND as a separator between keywords.
    ...                 The keywords are executed so that the first argument is the first keyword and proceeding
    ...                 arguments until the first AND are arguments to it. First argument after the first AND
    ...                 is the second keyword and proceeding arguments until the next AND are its arguments. And so on.

    ${db_name} =    Set Variable  My Cool Database
    @{servers} =    Create List     server-1    server-2    server-3
    Run Keywords 	initialize database 	${db_name} 	    AND 	start servers 	@{servers}

    ${keyword_one_with_args} =    Create List     initialize database    ${db_name}
    ${keyword_two_with_args} =    Create List     start servers  @{servers}
    Run Keywords    @{keyword_one_with_args}   AND   @{keyword_two_with_args}

Use "Set Global Variable"
    [Documentation]        Makes a variable available globally in all tests and suites
    Set Global Variable    ${DYNAMIC_GLOBAL_SCALAR}     dynamic global variable available across all tests suites (i.e. utilize-global-variable.robot)
    Set Global Variable    @{DYNAMIC_GLOBAL_LIST}       First item      Second Item        Third Item
    Set Global Variable    &{DYNAMIC_GLOBAL_DICTIONARY}     key=value

    # Also variables in variable tables are overridden (overriding the variable table of utilize-global-variable.robot)
    # In practice setting variables with this keyword has the same effect as using command line
    # options --variable and --variablefile. Because this keyword can change variables everywhere,
    # it should be used with care
    Set Global Variable    ${GLOBAL_VAR}        I am overridden and just became global

Use "Set Library Search Order"
    [Documentation]        Set Library Search Order 	*search_order
    ...                    Sets the resolution order to use when a name matches multiple keywords.
    ...                    The library search order is used to resolve conflicts when a keyword name in the test data matches multiple keywords.
    ...                    The first library (or resource, see below) containing the keyword is selected and that keyword implementation used.
    ...                    Note: in *** Settings *** table, we import 2 libraries:
    ...                    LibraryOneHavingAConflictingKeyword
    ...                    LibraryTwoHavingAConflictingKeyword
    ${original search order} =  Set Library Search Order    LibraryTwoHavingAConflictingKeyword  LibraryOneHavingAConflictingKeyword
    # lets invoke the 'conflicting keyword' and see which instance of it is invoked in which library
    ${library_name} =    conflicting keyword
    Should Be True  $library_name=='LibraryTwo'
    # lets swap the library search order to LibraryOneHavingAConflictingKeyword  LibraryTwoHavingAConflictingKeyword
    Set Library Search Order  LibraryOneHavingAConflictingKeyword   LibraryTwoHavingAConflictingKeyword
    # lets invoke the 'conflicting keyword' and see which instance of it is invoked in which library
    ${library_name} =    conflicting keyword
    Should Be True  $library_name=='LibraryOne'

    # This keyword can be used also to set the order of keywords in different resource files.
    # In this case resource names must be given without paths or extensions like:
    Import Resource     ResourceOneHavingAConflictingKeyword.resource
    Import Resource     ResourceTwoHavingAConflictingKeyword.resource
    Set Library Search Order    ResourceTwoHavingAConflictingKeyword      ResourceOneHavingAConflictingKeyword
    ${library_name} =       Another Conflicting Keyword
    Should Be True      $library_name=='Resource Two'

    # Keywords in resources always have higher priority than keywords in libraries regardless the search order
    # Here is an example, where ResourceTwoHavingAConflictingKeyword would be selected
    Set Library Search Order  LibraryOneHavingAConflictingKeyword   LibraryTwoHavingAConflictingKeyword   ResourceTwoHavingAConflictingKeyword  ResourceOneHavingAConflictingKeyword
    ${library_name} =      third conflicting keyword   # referring to the previous line, note that this keyword is defined in every resource and in every library
    Should Be True  $library_name=='Resource Two'

Use "Set Log Level"
    [Documentation]     Set Log Level 	level
    ...
    ...                 IMPORTANT! The behaviour of Log command is not consistent with the documentation
    ...                 Refer to the test implementation to see actual behaviour
    ...
    ...                 Documentation for the keyword says:
    ...                 Sets the log threshold to the specified level and returns the old level.
    ...                 Messages below the level will not logged. The default logging level is INFO, but
    ...                 it can be overridden with the command line option --loglevel.
    ...                 The available levels: TRACE (lowest), DEBUG, INFO (default), WARN, ERROR and NONE (highest, no logging).

    Set Log Level       ERROR  # has no effect if the command line option --loglevel is used
    Log      Log level=ERROR        level=ERROR         # logged
    Log      Log level=WARN         level=WARN          # logged
    Log      Log level=INFO         level=INFO          # logged
    Log      Log level=DEBUG        level=DEBUG         # logged
    Log      Log level=TRACE        level=TRACE         # logged

    Set Log Level       WARN  # has no effect if the command line option --loglevel is used
    Log      Log level=ERROR        level=ERROR         # logged
    Log      Log level=WARN         level=WARN          # logged
    Log      Log level=INFO         level=INFO          # not logged
    Log      Log level=DEBUG        level=DEBUG         # not logged
    Log      Log level=TRACE        level=TRACE         # not logged

    Set Log Level       INFO  # has no effect if the command line option --loglevel is used
    Log      Log level=ERROR        level=ERROR         # logged
    Log      Log level=WARN         level=WARN          # logged
    Log      Log level=INFO         level=INFO          # logged
    Log      Log level=DEBUG        level=DEBUG         # not logged
    Log      Log level=TRACE        level=TRACE         # not logged

    Set Log Level       DEBUG  # has no effect if the command line option --loglevel is used
    Log      Log level=ERROR        level=ERROR         # logged
    Log      Log level=WARN         level=WARN          # logged
    Log      Log level=INFO         level=INFO          # logged
    Log      Log level=DEBUG        level=DEBUG         # not logged
    Log      Log level=TRACE        level=TRACE         # not logged

    Set Log Level       TRACE  # has no effect if the command line option --loglevel is used
    Log      Log level=ERROR        level=ERROR         # logged
    Log      Log level=WARN         level=WARN          # logged
    Log      Log level=INFO         level=INFO          # logged
    Log      Log level=DEBUG        level=DEBUG         # not logged
    Log      Log level=TRACE        level=TRACE         # not logged

Use "Set Suite Documentation"
    [Documentation]     Set Suite Documentation 	doc, append=False, top=False
    ...                 Sets documentation for the current test suite.
    ...                 By default the possible existing documentation is overwritten,
    ...                 but this can be changed using the optional append argument.
    ${to be appended} =        Set Variable     This sentence is added to the suite documentation
    Set Suite Documentation     ${to be appended}   append=True
    # The documentation of the current suite is available as a built-in variable ${SUITE DOCUMENTATION}.
    Should Be True      "${to be appended}" in "${SUITE DOCUMENTATION}"

Use "Set Suite Metadata"
    [Documentation]     Set Suite Metadata 	name, value, append=False, top=False
    ...                 Sets metadata for the current test suite.
    ...                 The metadata of the current suite is available as a built-in variable ${SUITE METADATA}
    ...                 in a Python dictionary. Notice that modifying this variable directly has no effect on the
    ...                 actual metadata the suite has
    Log      ${SUITE METADATA}   # logs an empty dictionary {}
    Set Suite Metadata    key1   value    append=True
    Log      ${SUITE METADATA}   # logs a dictionary: {'key1':'value'}
    Set Suite Metadata    key2   ${6}    append=True
    Log      ${SUITE METADATA}   # logs a dictionary: {'key1':'value', 'key2': '6'}  <-- 6 is a string, not integer

(Test 1/3) Use "Set Suite Variable"
    [Documentation]     https://robotframework.org/robotframework/latest/libraries/BuiltIn.html#Set%20Suite%20Variable
    ...                 Set Suite Variable 	name, *values
    ...                 Makes a variable available everywhere within the scope of the current suit
    Set Suite Variable  @{PARENT-SUITE-ONLY-LIST}     Item 1     ${2}   Item 3
    Set Suite Variable  &{ALSO-CHILD-SUITE-ACCESSIBLE-DICT}   key=value      children=True

(Test 2/3) Use "Set Suite Variable"
    Variable Should Exist   @{PARENT-SUITE-ONLY-LIST}               # Passes as it should be
    Variable Should Exist   &{ALSO-CHILD-SUITE-ACCESSIBLE-DICT}     # Passes as it should be

(Test 3/3) Child Test Suite Accessing Variable "ALSO-CHILD-SUITE-ACCESSIBLE-DICT"
    [Documentation]     https://stackoverflow.com/questions/59929794/robot-fw-builtin-module-set-suite-variable-how-to-pass-the-suite-variabl
    ...                 The goal is to have and is to call a simple child test suite, which checks the following:
    ...                 @{PARENT-SUITE-ONLY-LIST}   is NOT availabe in the child test suite
    ...                 &{ALSO-CHILD-SUITE-ACCESSIBLE-DICT} is indeed available in the child test suite
    [Tags]              not-understood
    Fail        Should Be Implemented

(Test 1/3) Use "Set Suite Variable": Override A Variable In The Test Case Scope
    [Documentation]     https://stackoverflow.com/questions/59933909/robot-fw-builtin-module-set-suite-variable-how-to-overwrite-the-newly-crea
    ...                 "If a variable already exists within the new scope, its value will be overwritten."
    ...                 "If a variable already exists within the test case scope, its value will be overridden"
    ...                 Otherwise a new variable is created.
    # Set a variable in the test scope
    Set test variable  ${var}  test
    Should be equal    ${var}  test

    # Set a suite variable that has the same name as the local variable
    Set suite variable  ${var}  suite

    # Even though we set it as a suite scope, it 'overwrites' the local variable of the same name
    Should be equal  ${var}  suite   # passes

    # if a variable does not exist within the test case scope, a new variable is created
    Set Suite Variable  ${var2}  suite

(Test 2/3) Use "Set Suite Variable": Override A Variable In The Test Case Scope
    # Verify the suite variable from the previous test is visible in this new test scope
    Should be equal  ${var}  suite   # passes
    Should Be Equal  ${var2}  suite  # passes
    # we can re-set the suite scoped variable as a test scoped variable
    Set test variable  ${var}  test   # do not use test suite scoped ${var}
    Should be equal    ${var}  test   # passes

(Test 3/3) Use "Set Suite Variable": What does var have in this test?
    # the keyword works pretty much exactly as described,
    # it sets a suite variable to a value. It either changes an existing variable or creates a new one
    Should be equal  ${var}  suite  # passes

(Test 1/2) Use "Set Suite Variable" : Set Locally Scoped Variable As Suite Scoped
    [Documentation]     https://stackoverflow.com/questions/59945461/robot-fw-buitlin-library-set-suite-variable-how-to-pass-the-variable-withi/59946962#59946962
    ...                 Set Suite Variable:
    ...                 If a variable already exists within the current scope (i.e. Test 1/2), the value can be left empty and
    ...                 the variable within the new scope (i.e. Test 2/2) gets the value within the current scope
    ...                 (i.e Test 1/2)
    Set Test Variable       ${local_to_suite_scoped}    ${3}
    Set Suite Variable      ${local_to_suite_scoped}    # intentionally not setting any value to comply with the [Documentation]

(Test 2/2) Use "Set Suite Variable" : Use local_to_suite_scoped in this test
    Variable Should Exist   ${local_to_suite_scoped}
    Should Be Equal         ${local_to_suite_scoped}     ${3}  # passes as expected

(Test 1/2) Use "Set Suite Variable" : The Variable Has Value, Which Itself Is A Variable
    [Documentation]         If the variable has value which itself is a variable (escaped or not),
    ...                     you must always use the escaped format to set the variable
    # note that ${var} is suite scoped with value 'suite'
    Should Be Equal     ${var}      suite
    ${NAME} = 	Set Variable 	\${var}         # ${NAME} has value which itself is a variable
    Should Be Equal     ${NAME}     \${var}     # passes
    Set Suite Variable 	${NAME} 	X 	# Sets variable ${var} with X
    Should Be Equal     ${var}      X   # passes
    Set Suite Variable 	\${NAME} 	Y 	# Sets variable ${NAME} ==> You must always use the escaped format to set the variable
    Should Be Equal     ${NAME}     Y   # ${NAME} no more pointing to ${var}

(Test 2/2) Use "Set Suite Variable" : var should have value "X"
    Should Be True     $var=='X'

Use "Set Task Variable"
    [Documentation]     "Set Task Variable" is an alias to "Set Test Variable". New to RF 3.1
    Set Task Variable  @{ListX}     item1      item2
    This Keyword Must Access ListX      # and it does

Use "Set Test Documentation"
    [Documentation]     Set Test Documentation 	doc, append=False
    ...                 Sets documentation for the current test case.
    ...                 By default the possible existing documentation is overwritten, but this can be changed using
    ...                 the optional 'append' argument
    ...                 The current test documentation is available as a built-in variable ${TEST DOCUMENTATION}
    Log         ${TEST DOCUMENTATION}
    Set Test Documentation      This overwrites the [Documentation]
    Log         ${TEST DOCUMENTATION}


(Test 1/3) Use "Set Test Message"
    [Documentation]      Set Test Message 	message, append=False
    ...                  Sets message for the current test case
    ...                  If the optional append argument is given a true value (see Boolean arguments),
    ...                  the given message is added after the possible earlier message by joining the messages with a space.
    ...                  Notice that in teardown the message is available as a built-in variable ${TEST MESSAGE}.
    Set Test Message     Test Message Begin
    Set Test Message     Test Message End    append=True
    [Teardown]           (Test 1/3) Use "Set Test Message" - Teardown

(Test 2/3) Use "Set Test Message" In Teardown Overriding Failure Message
    [Documentation]      In test teardown this keyword can alter the possible failure message
    [Tags]               failure-expected
    Should Be True    ${False}  # an intentional failure
    [Teardown]        (Test 2/3) Use "Set Test Message" - Teardown Overriding The Failure Message

(Test 3/3) Use "Set Test Message"
    [Documentation]      In case this keyword is used and after that a failure occurs, the failure overrides
    ...                  the message set by this keyword
    [Tags]               failure-expected
    Set Test Message     Test Message Begin
    Set Test Message     Test Message End    append=True
    Should Be True       ${False}  # an intentional failure
    [Teardown]           (Test 1/3) Use "Set Test Message" - Teardown  # it reads the test's message

Use "Set Test Variable"
    [Documentation]     Set Test Variable 	name, *values
    ...                 Makes a variable available everywhere within the scope of the current test.
    ...                 Variables set with this keyword are available everywhere within the scope of the currently
    ...                 executed test case. For example, if you set a variable in a user keyword, it is available
    ...                 both in the test case level and also in all other user keywords used in the current test.
    ...                 Other test cases will not see variables set with this keyword.
    Keyword Creating A Test Variable
    Log     ${test-scoped-var}
    Keyword Logging The Test Variable

Use "Set Variable"
    [Documentation]     Set Variable 	*values
    ...                 Returns the given values which can then be assigned to a variables.
    ...                 This keyword is mainly used for setting scalar variables.
    ${local_scalar} =   Set Variable   Value of suite var is ${var}

    # Additionally it can be used for converting a scalar variable containing a list to a list variable
    ${local_list} =     Create List     ${1}    ${2}    ${3}
    @{local_list_2} =   Set Variable    ${local_list}

    # Also, it can be used for converting a scalar variable containing a list to multiple scalar variables.
    ${item1}    ${item2}    ${item3} =    Set Variable    ${local_list}

Use "Set Variable If"
    [Documentation]     Set Variable If 	condition, *values
    ...                 Sets variable based on the given condition.
    ...                 The basic usage is giving a condition and two values. The given condition is first
    ...                 evaluated the same way as with the Should Be True keyword. If the condition is true,
    ...                 then the first value is returned, and otherwise the second value is returned.
    ...                 The second value can also be omitted, in which case it has a default value None.
    ${x} =      Set Variable     ${0}

    ${var1} = 	Set Variable If 	${x} == 0 	zero 	nonzero
    Should Be True  $var1=='zero'   # passes

    ${var2} = 	Set Variable If 	${x} > 0 	value1 	value2
    Should Be True  $var2=='value2'   # passes

    ${var3} = 	Set Variable If 	${x} > 0 	whatever
    Should Be True  $var3==None       # passes

    # It is also possible to have 'else if' support by replacing the second value with another condition,
    # and having two new values after it. If the first condition is not true, the second is evaluated and
    # one of the values after it is returned based on its truth value.
    # This can be continued by adding more conditions without a limit.
    ${var} = 	Set Variable If 	${x} == 0 	zero
    ... 	${x} > 0 	greater than zero 	less then zero
    Should Be True  $var=='zero'

    ${x} =      Set Variable    ${-1}
    ${var} = 	Set Variable If
    ... 	${x} == 0 	zero
    ... 	${x} == 1 	one
    ... 	${x} == 2 	two
    ... 	${x} > 2 	greater than two
    ... 	${x} < 0 	less than zero
    Should Be True      $var=='less than zero'

Use "Should Be Empty"
    [Documentation]     Should Be Empty 	item, msg=None
    ...                 Verifies that the given item is empty.
    ...                 The length of the item is got using the 'Get Length' keyword.
    ...                 The default error message can be overridden with the msg argument
    @{lst} =            Create List     # an empty list
    Should Be Empty     ${lst}  msg='Length is indeed zero'  # there is no error, so the msg not shown

Use "Should Be Equal"
    [Documentation]     Should Be Equal 	first, second, msg=None, values=True, ignore_case=False, formatter=str
    ...                 Fails if the given objects are unequal.
    ...                 Optional msg, values and formatter arguments specify how to construct the error message
    ...                 if this keyword fails:

    # If msg is not given, the error message is <first> != <second>
    Run Keyword And Ignore Error    Should Be Equal      first   second  # an intended failure

    # If msg is given and values gets a true value (default), the error message is <msg>: <first> != <second>
    Run Keyword And Ignore Error    Should Be Equal      first   second     msg='This is the error message'

    # If msg is given and values gets a true value (default), the error message is <msg>: <first> != <second>
    Run Keyword And Ignore Error    Should Be Equal      first   second     msg='This is the error message'  values=False

    # If ignore_case is given a true value (see Boolean arguments) and both arguments are strings, comparison is done case-insensitively
    Should Be Equal     iGnoRE Case     ignore case     ignore_case=True

Use "Should Be Equal As Integers"
    [Documentation]     Should Be Equal As Integers 	first, second, msg=None, values=True, base=None
    ...                 Fails if objects are unequal after converting them to integers.
    Should Be Equal As Integers     42      ${42}       # base 10, passed
    Should Be Equal As Integers     0xA     0xA         # base 16, passed
    # base 2, fails intentionally
    Run Keyword And Ignore Error     Should Be Equal As Integers     0b1011  0b1000     msg='After converting to int'

Use "Should Be Equal As (Real) Numbers"
    [Documentation]     Should Be Equal As Numbers 	first, second, msg=None, values=True, precision=6
    ...                 Fails if objects are unequal after converting them to real numbers.
    ...                 The conversion is done with Convert To Number keyword using the given precision.
    Set Test Variable   ${x}    ${1.1}
    Should Be Equal As Numbers 	${x} 	1.1 		# Passes if ${x} is 1.1
    Should Be Equal As Numbers 	1.123 	1.1 	precision=1 	# Passes
    Should Be Equal As Numbers 	1.123 	1.4 	precision=0 	# Passes
    Should Be Equal As Numbers 	112.3 	75 	    precision=-2 	# Passes

Use "Should Be Equal As Strings"
    [Documentation]     Should Be Equal As Strings 	first, second, msg=None, values=True, ignore_case=False, formatter=str
    ...                 Fails if objects are unequal after converting them to strings.
    ...                 See Should Be Equal for an explanation on how to override the default error
    ...                 message with msg, values and formatter.
    ...                 If ignore_case is given a true value (see Boolean arguments), comparison is done case-insensitively.
    ${string_one} =     Set Variable  Lorem Ipsum
    ${string_two} =     Set Variable  lorem ipsum
    Run Keyword And Ignore Error    Should Be Equal As Strings      ${string_one}   ${string_two}
    Should Be Equal As Strings      ${string_one}   ${string_two}  ignore_case=True

    # If both arguments are multiline strings, this keyword uses multiline string comparison.
    ${line_seperator} =     Evaluate    os.linesep      modules=os  # will not print anything in the test log file
    ${multi_line_string_one} =      Catenate    SEPARATOR=${line_seperator}     Not in second 	    Same 	Differs 	Same
    ${multi_line_string_two} =      Catenate    SEPARATOR=${line_seperator}     Same 	Differs2 	Same 	Not in first
    Should Be Equal As Strings      ${multi_line_string_one}        ${multi_line_string_one}
    Run Keyword And Ignore Error    Should Be Equal As Strings      ${multi_line_string_one}     ${multi_line_string_two}

(Test 1/3): Use "Should Be True"
    @{list} =   Create List     a   b   c
    # Variables used like ${list}, as in this example, are replaced with their string representation
    # in the expression before evaluation
    Should Be True      ${list} == ['a', 'b', 'c']

    ${list} = 	Create List 	${1} 	${2} 	${3}
    # Robot 2.9 onwards: Variables are also available in the evaluation namespace and can be accessed
    # using special syntax $list
    Should Be True      $list == [1, 2, 3]

    # Should Be True automatically imports Python's os and sys modules that contain several useful attributes:
    Should Be True 	    os.linesep == '\\n' 	        # Unixy, note that \ character must be escaped with \
    Should Be True 	    sys.platform == 'linux'

(Test 2/3): Use "Should Be True"
    [Documentation]     This is an example to the following question
    ...                 https://stackoverflow.com/questions/59788997/what-are-the-steps-behind-should-be-true-hex-value-0xff-expression-in-r
    ${hex_value} = 	    Convert To Hex 	255   base=10  prefix=0x		# Result is 0xFF as a string
    # Question: How does the following statement work?
    Should Be True      ${hex_value}==${0xFF}           #: is ${0xFF} a string or a integer value in base 16?

    # TARGET:
    # Should Be True      a_python_expression_in_a_string_without_quotes      # i.e.   0xFF==255

    # STEP 1: When a variable is used in the expressing using the normal ${hex_value} syntax,
    # its value is replaced before the expression is evaluated.
    # This means that the value used in the expression will be the string representation of the variable value,
    # not the variable value itself.
    Should Be True      0xFF==${0xFF}

    # Step 2: When the hexadecimal value 0xFF is given in ${} decoration, robot converts the value to its
    # integer representation 255 and puts the string representation of 255 into the the expression
    Should Be True      0xFF==255

(Test 3/3): Use "Should Be True"
    [Documentation]   Example to the question:
    ...               https://stackoverflow.com/questions/59791437/what-is-the-difference-between-should-be-true-list-a-b-c-ands
    @{list} =           Create List     a   b   c
    Should Be True      ${list} == ['a', 'b', 'c']    # like running eval("['a', 'b', 'c'] == ['a', 'b', 'c']") on python console
    Should Be True      $list == ['a', 'b', 'c']

Use "Should Contain"
    [Documentation]     Should Contain 	container, item, msg=None, values=True, ignore_case=False
    ...                 Fails if container does not contain item one or more times
    ...                 Works with strings, lists, dictionaries and anything that supports Python's in operator.

    # with strings
    ${s} =              Set Variable    Lorem Ipsum
    ${search} =         Set Variable    lorem   # note the lowercase
    Run Keyword And Ignore Error        Should Contain      container=${s}    item=${search}  # case sensitive search, should fail
    Should Contain      container=${s}    item=${search}   ignore_case=True

    # with lists
    ${l} =              Create List         ${1}    ${2}    ${3}
    ${search} =         Set Variable        ${2}
    Should Contain      container=${l}      item=${search}
    Run Keyword And Ignore Error     Should Contain     container=${l}   item=${100}

    # with dictionaries
    ${d} =              Create Dictionary   key1=value1     key2=value2
    ${search} =         Set Variable        key1
    Should Contain      container=${d}      item=${search}
    Run Keyword And Ignore Error      Should Contain    container=${d}      item=key3

Use "Should Contain Any"
    [Documentation]     Should Contain Any 	container, *items, **configuration
    ...                 Works with strings, lists, dictionaries and anything that supports Python's in operator.
    ...                 Supports additional configuration parameters msg, values and ignore_case, which have exactly
    ...                 the same semantics as arguments with same names have with Should Contain. These arguments must
    ...                 always be given using name=value syntax after all items.
    ...                 New in Robot Framework 3.0.1.

    # with strings
    ${s} =              Set Variable    Lorem Ipsum
    Should Contain Any      ${s}     REM     xx       msg='Overwriding msg'   values=True   ignore_case=True
    Run Keyword And Ignore Error    Should Contain Any      ${s}     REM     xx       msg='Overwriding msg'   values=True   ignore_case=False

    # with lists
    ${l} =              Create List         ${1}    ${2}    ${3}
    Should Contain Any      ${l}    ${2}
    Run Keyword And Ignore Error    Should Contain Any      ${l}    ${100}   ${200}   ${300}

    # with dictionaries
    ${d} =              Create Dictionary   key1=value1     key2=value2
    Should Contain Any      ${d}        key1    key5
    Run Keyword And Ignore Error    Should Contain Any      ${d}    key5    key7

    # Note that possible equal signs in items must be escaped with a backslash (e.g. foo\=bar)
    # to avoid them to be passed in as **configuration
    ${l} =      Create List     item\=1     item\=2     item\=3
    Should Contain Any      ${l}    foo\=bar     item\=3
    Run Keyword And Ignore Error    Should Contain Any      ${l}    foo\=bar     item\=4    msg='Overwriting msg'  values=True  ignore_case=False

Use "Should Contain X Times"
    [Documentation]     Should Contain X Times 	item1, item2, count, msg=None, ignore_case=False
    ...                 Fails if item1 does not contain item2 count times.
    ...                 Works with strings, lists, tuples and dictionaries and all objects that Get Count works with.
    ...                 (Get Count works with all Python objects that can be converted to a list)
    ...                 The default error message can be overridden with msg and the actual count is always logged.

    # with strings
    ${s} =              Set Variable    Lorem Ipsum Lorem Ipsum Lorem Ipsum
    Run Keyword And Ignore Error    Should Contain X Times  ${s}    lorem ipsum  count=${3}   # note the casing
    Should Contain X Times  ${s}    lorem ipsum  count=3  msg='The new error msg'  ignore_case=True   # note the casing
    Run Keyword And Ignore Error    Should Contain X Times  ${s}    lorem ipsum  count=2  msg='The new error msg'  ignore_case=True   # note the casing

    # with lists
    ${lst} =              Create List         ${2}    ${2}    ${2}
    Should Contain X Times      ${lst}    ${2}  count=${3}
    Run Keyword And Ignore Error    Should Contain X Times  ${lst}  ${5}  count=${2}  msg='The overwriting error msg'

    # with tuples
    ${t} =      get tuple   # From Utils.py, ('a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1,)
    Should Contain X Times      ${t}    a   count=${2}
    Should Contain X Times      ${t}    ${1}   count=${3}

    # with dictionaries
    ${d} =              Create Dictionary   key1=value1     key2=value2
    Should Contain X times      ${d}    key1    count=${1}
    Should Contain X times      ${d}    key5    count=${0}

Use "Should End With"
    [Documentation]     Should End With 	str1, str2, msg=None, values=True, ignore_case=False
    ...                 Fails if the string str1 does not end with the string str2.
    ...                 See Should Be Equal for an explanation on how to override the default error message with msg
    ...                 and values, as well as for semantics of the ignore_case option.
    ${s} =              Set Variable    Lorem Ipsum
    ${search} =         Set Variable    ipsum   # note the casing
    Run Keyword And Ignore Error        Should End With     ${s}    ${search}   # case sensitive search
    Should End With     ${s}    ${search}   ignore_case=True      # case insensitive search

Use "Should Match"
    [Documentation]     https://stackoverflow.com/questions/59967941/robot-framework-builtin-library-should-match-how-to-pass-a-pattern-paramet
    ...                 Should Match 	string, pattern, msg=None, values=True, ignore_case=False
    ...                 Fails if the given string does not match the given pattern.
    ...                 Pattern matching is similar as matching files in a shell with *, ? and [chars] acting as
    ...                 wildcards. See the Glob patterns section for more information.
    ...                 When using "Should Match" the pattern needs to match the whole string, not just part of the string.
    ...                 If you want the first pattern to pass, you need to change it to *me*. The first star will match
    ...                 everything up to the word "me", and the second star will match everything after.
    ...                 The same is true for the other patterns. If you're looking for a pattern inside a larger
    ...                 string you need to add * on either side of the pattern to match all of the other characters
    Run Keyword And Ignore Error        Should Match    string=Cannot find anything here   pattern=*not found*   msg='The overwriting msg'
    Should Match        string=Can find me here   pattern=*me*   msg='The overwriting error'  # passes
    Should Match        string=Will match with star   pattern=*              # passes
    Should Match        string=Will match this        pattern=*[atx]his      # passes
    Should Match        string=Will match with keyword    pattern=*?eyword    # passes

Use "Should Match Regexp"
    [Documentation]     Come back here once studied regular expressions in Python
    [Tags]              not-understood
    Fail    Test needs to be implemented

Use "Should Not Be Empty"
    [Documentation]     Should Not Be Empty 	item, msg=None
    ...                 Verifies that the given item is not empty.
    ...                 The length of the item is got using the Get Length keyword.
    ...                 The default error message can be overridden with the msg argument.

    # The keyword first tries to get the length with the Python function len, which calls the item's __len__ method internally
    # note that len(any_list) will return the length value
    @{list} =           get list      # from Utils.py: ['a', 'b', 'a', 'c', 1, 0, 3, 1, 2, 1]
    Should Not Be Empty     ${list}     msg='This msg wont show as there is no error'

    # If that fails, the keyword tries to call the item's possible length and size methods directly
    ${string_wrapper} =   get_string_wrapper  I am a string of length 26    # from Utils.py
    Should Not Be Empty      item=${string_wrapper}   msg='This msg wont show as there is no error'

    # The final attempt is trying to get the value of the item's 'length' attribute
    Should Not Be Empty      item=${utility_object}     msg='This msg wont show as there is no error'

    # all the above attempts fail, Get Length will fail
    Run Keyword And Ignore Error    Should Not Be Empty   ${5}   msg='The overwriting error msg'

Use "Should Not Be Equal"
    [Documentation]     Should Not Be Equal 	first, second, msg=None, values=True, ignore_case=False
    ...                 Fails if the given objects are equal.
    ...                 See Should Be Equal for an explanation on how to override the default error message with msg and values.
    ...                 If ignore_case is given a true value (see Boolean arguments) and both arguments are strings,
    ...                 comparison is done case-insensitively. New option in Robot Framework 3.0.1.
    Run Keyword And Ignore Error    Should Not Be Equal      Case insensitive String     case insensitive string     ignore_case=True   msg='Overwriting error msg'
    Should Not Be Equal      Case insensitive String     case insensitive string     ignore_case=False

    # https://stackoverflow.com/questions/59982565/robot-fw-builtin-library-should-not-be-equal-0b1011-11-passes-but-its-shoul
    # Because by default, all arguments to keywords are passed as strings.
    Should Not Be Equal     0b1011    11    # "0b1011" != "11" which is True
    Should Not Be Equal     0b1011    0xB   # "0b1011" != "0xB" which is True
    # If you want to check the integers/numerical values, this is the way:
    Run Keyword And Ignore Error    Should Not Be Equal     ${0b1011}   ${0xB}      # 11 == 11 in base 10

Use "Should Not Be Equal As Integers"
    [Documentation]     https://stackoverflow.com/questions/59982565/robot-fw-builtin-library-should-not-be-equal-0b1011-11-passes-but-its-shoul
    ...                 Should Not Be Equal As Integers 	first, second, msg=None, values=True, base=None
    ...                 Fails if objects are equal after converting them to integers.
    ...                 See Convert To Integer for information how to convert integers from other bases than 10
    ...                 using base argument or 0b/0o/0x prefixes.
    ...                 See Should Be Equal for an explanation on how to override the default error message with msg and values.
    Should Not Be Equal As Integers     10       11
    Run Keyword And Ignore Error    Should Not Be Equal As Integers     0b1011    11   # should fail, but passes. Why?
    Run Keyword And Ignore Error    Should Not Be Equal As Integers     0b1011    0xB  # should fail, but passes, Why?
    Run Keyword And Ignore Error    Should Not Be Equal As Integers     0b1011    0b1011   msg='Overriding error msg'  values=True


Use "Should Not Be Equal As Numbers"
    [Documentation]     Should Not Be Equal As Numbers 	first, second, msg=None, values=True, precision=6
    ...                 Fails if objects are equal after converting them to real numbers.
    Run Keyword And Ignore Error    Should Not Be Equal As Numbers      first=${1.123}  second=${1.345}     msg='The overwriting error msg'  precision=0
    Should Not Be Equal As Numbers      first=${1.123}  second=${1.345}     msg='The overwriting error msg'  precision=1  # 1.1 != 1.3

Use "Should Not Be Equal As Strings"
    [Documentation]     https://github.com/robotframework/robotframework/blob/master/src/robot/libraries/BuiltIn.py
    [Tags]              not-understood
    Fail                Implement this case

Use "Should Not Be True"
    [Documentation]      Should Not Be True 	condition, msg=None
    Run Keyword And Ignore Error     Should Not Be True      os.linesep == '\n'     msg='The expected overwriting error msg in Linux'

Use "Should Not Contain"
    [Documentation]     Should Not Contain 	container, item, msg=None, values=True, ignore_case=False
    ...                 Fails if container contains item one or more times
    ...                 Works with strings, lists, dictionaries and anything that supports Python's in operator.

    # with strings
    ${s} =              Set Variable    Lorem Ipsum
    ${search} =         Set Variable    lorem   # note the lowercase
    Should Not Contain      container=${s}    item=${search}  # case sensitive search, should fail
    Run Keyword And Ignore Error        Should Not Contain      container=${s}    item=${search}   ignore_case=True

    # with lists
    ${l} =              Create List         ${1}    ${2}    ${3}
    ${search} =         Set Variable        ${2}
    Run Keyword And Ignore Error        Should Not Contain      container=${l}      item=${search}
    Should Not Contain     container=${l}   item=${100}

    # with dictionaries
    ${d} =              Create Dictionary   key1=value1     key2=value2
    ${search} =         Set Variable        key1
    Run Keyword And Ignore Error      Should Not Contain    container=${d}      item=${search}
    Should Not Contain    container=${d}      item=key3

Use "Should Not Contain Any"
    [Documentation]     Should Not Contain Any 	container, *items, **configuration
    ...                 Works with strings, lists, dictionaries and anything that supports Python's in operator.
    ...                 Supports additional configuration parameters msg, values and ignore_case, which have exactly
    ...                 the same semantics as arguments with same names have with Should Contain. These arguments must
    ...                 always be given using name=value syntax after all items.
    ...                 New in Robot Framework 3.0.1.

    # with strings
    ${s} =              Set Variable    Lorem Ipsum
    Run Keyword And Ignore Error     Should Not Contain Any      ${s}     REM     xx       msg='Overwriding msg'   values=True   ignore_case=True
    Should Not Contain Any      ${s}     REM     xx       msg='This error msg wont show'   values=True   ignore_case=False

    # with lists
    ${l} =              Create List         ${1}    ${2}    ${3}
    Run Keyword And Ignore Error    Should Not Contain Any      ${l}    ${2}
    Should Not Contain Any      ${l}    ${100}   ${200}   ${300}

    # with dictionaries
    ${d} =              Create Dictionary   key1=value1     key2=value2
    Run Keyword And Ignore Error        Should Not Contain Any      ${d}        key1    key5
    Should Not Contain Any      ${d}    key5    key7

    # Note that possible equal signs in items must be escaped with a backslash (e.g. foo\=bar)
    # to avoid them to be passed in as **configuration
    ${l} =      Create List     item\=1     item\=2     item\=3
    Run Keyword And Ignore Error    Should Not Contain Any      ${l}    foo\=bar     item\=3
    Should Not Contain Any      ${l}    foo\=bar     item\=4    msg='This error msg wont show'  values=True  ignore_case=False

Use "Should Not End With"
    [Documentation]         Should Not End With 	str1, str2, msg=None, values=True, ignore_case=False
    ...                     Fails if the string str1 ends with the string str2.
    ...                     See Should Be Equal for an explanation on how to override the default error message with msg
    ...                     and values, as well as for semantics of the ignore_case option.
    Run Keyword And Ignore Error    Should Not End With     Lorem ipsum    ipSum    msg='Overwriting error msg'     ignore_case=True
    Should Not End With     Lorem ipsum    ipSum    msg='Overwriting error msg'     ignore_case=False

Use "Should Not Match"
    [Documentation]         Should Not Match 	string, pattern, msg=None, values=True, ignore_case=False
    ...                     Fails if the given string matches the given pattern
    ...                     Fails if the given string matches the given pattern.
    ...                     Pattern matching is similar as matching files in a shell with *, ? and [chars] acting as wildcards.
    ...                     See the Glob patterns section for more information.
    ...                     See Should Be Equal for an explanation on how to override the default error message with msg and values, as well as for semantics of the ignore_case option.

    Should Not Match    string=Cannot find anything here   pattern=*not found*   msg='Wont show as there is no error'
    Run Keyword And Ignore Error    Should Not Match    string=Can find me here   pattern=*me*   msg='The overwriting error'  # fails as expected
    Run Keyword And Ignore Error    Should Not Match    string=Will match with star   pattern=*     # fails as expected
    Run Keyword And Ignore Error    Should Not Match        string=Will match this        pattern=*[atx]his      # fails as expected
    Run Keyword And Ignore Error    Should Not Match        string='Will match with keyword'    pattern=*?eyword*    # fails as expected

Use "Should Not Match Regexp"
    [Tags]      not-understood
    Fail    Understand regex first and implement this

Use "Should Not Start With"
    [Documentation]         Should Not Start With 	str1, str2, msg=None, values=True, ignore_case=False
    ...                     Fails if the string str1 starts with the string str2.
    Should Not Start With       does not start with     X     msg=Wont show as there is no error
    Run Keyword And Ignore Error    Should Not Start With       does start with     DOES     msg=Will show as there is error  ignore_case=True

Use "Should Start With"
    [Documentation]         Should Start With 	str1, str2, msg=None, values=True, ignore_case=False
    ...                     Fails if the string str1 does not start with the string str2.
    Run Keyword And Ignore Error    Should Start With       does not start with     X     msg=Wont show as there is no error
    Should Start With       does start with     DOES     msg=Wont show as there is no error     ignore_case=True

Use "Sleep"
    [Documentation]         Sleep 	time_, reason=None
    ...                     Pauses the test executed for the given time.
    ...                     time may be either a number or a time string. Time strings are in a format such as 1 day
    ...                     2 hours 3 minutes 4 seconds 5milliseconds or 1d 2h 3m 4s 5ms
    Sleep       time_=1s    reason=Just to use Sleep

Use "Variable Should Exist"
    [Documentation]         Variable Should Exist 	name, msg=None
    ...                     Fails unless the given variable exists within the current scope.
    ...                     The name of the variable can be given either as a normal variable name (e.g. ${NAME})
    ...                     or in escaped format (e.g. \${NAME}). Notice that the former has some limitations explained in Set Suite Variable.
    ...                     The default error message can be overridden with the msg argument.

    &{locally_available_variables} =    Get Variables       # Returns a dictionary containing all variables in the current scope
    Log     ${locally_available_variables}
    Variable Should Exist   \&{DICTIONARY}
    Variable Should Exist   \@{DYNAMIC_GLOBAL_LIST}
    Run Keyword And Ignore Error    Variable Should Exist   ${non-existing-var}  msg='Overriding error msg'

Use "Variable Should Not Exist"
    [Documentation]         Refer to the test above: Use "Variable Should Exist"
    ...                     This keyword does the opposite of "Variable Should Exist"
    Variable Should Not Exist   ${non-existing-var}  msg='Wont show as there is no error'

Use "Wait Until Keyword Succeeds"
    [Documentation]         Wait Until Keyword Succeeds 	retry, retry_interval, name, *args
    ...                     Runs the specified keyword and retries if it fails
    ...                     If the keyword does not succeed regardless of retries, this keyword fails.
    ...                     If the executed keyword passes, its return value is returned
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds 	3x 	 100ms 	    raise type error in python      a       b       c
    ${total} =    Wait Until Keyword Succeeds    3x 	 100ms     add_multiple_values      ${1}     ${2}      ${3}
    Should Be Equal         ${total}        ${6}