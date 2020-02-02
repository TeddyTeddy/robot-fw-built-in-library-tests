*** Settings ***
Documentation    This parent suite uses "Set Suite Variable" keyword (from  builtin) to
...              create two variables. Refer to /child-suites/child-suite.robot

*** Test Cases ***
Create Variables via "Set Suite Variable" Keyword
    Set Suite Variable  @{PARENT-SUITE-ONLY-LIST}     Item 1     ${2}   Item 3
    Set Suite Variable  &{CHILD-SUITE-ACCESSIBLE-DICT}   key=value      children=${True}