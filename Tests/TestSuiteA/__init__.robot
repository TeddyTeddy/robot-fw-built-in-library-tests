*** Settings ***
Documentation    This parent suite uses "Set Suite Variable" keyword (from  builtin) to
...              create two variables.

Suite Setup      Create Variables via "Set Suite Variable" Keyword

*** Keywords ***
Create Variables via "Set Suite Variable" Keyword
    Set Suite Variable  @{x}     Item 1     ${2}   Item 3       children=${True}
    Set Suite Variable  &{y}     key=value      children=${True}
    Set Suite Variable  ${z}     Not to be passed to child suites      children=${False}
