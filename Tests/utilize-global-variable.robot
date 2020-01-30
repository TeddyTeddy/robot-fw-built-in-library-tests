*** Settings ***
Documentation       built-in-library-test.robot  declares  DYNAMIC_GLOBAL_VARIABLE and this suite logs it

*** Variables ***
${GLOBAL_VAR}       I must be overridden by 'Use "Set Global Variable"' test case in built-in-library-test.robot

*** Test Cases ***
Log Dynamic Variables Created In built-in-library-test.robot
    Log             ${DYNAMIC_GLOBAL_SCALAR}
    Log             ${DYNAMIC_GLOBAL_LIST}
    Log             ${DYNAMIC_GLOBAL_DICTIONARY}

Check GLOBAL_VAR Value
    Should Be Equal     ${GLOBAL_VAR}       I am overridden and just became global



