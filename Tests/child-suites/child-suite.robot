*** Settings ***
Documentation    Suite description

*** Test Cases ***
Check Variables ${x} and ${y}
    Variable Should Not Exist  \@{x}
    Variable Should Exist      \&{y}