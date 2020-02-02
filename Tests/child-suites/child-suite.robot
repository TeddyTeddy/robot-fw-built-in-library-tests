*** Settings ***
Documentation    Suite description

*** Test Cases ***
Check Variables PARENT-SUITE-ONLY-LIST and CHILD-SUITE-ACCESSIBLE-DICT
    Variable Should Not Exist  \${PARENT-SUITE-ONLY-LIST}
    Variable Should Exist      \${CHILD-SUITE-ACCESSIBLE-DICT}