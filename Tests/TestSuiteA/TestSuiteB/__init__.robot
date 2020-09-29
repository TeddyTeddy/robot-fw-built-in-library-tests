*** Settings ***
Documentation    Parent TestSuiteA uses "Set Suite Variable" keyword (from  builtin) to
...              create two variables. Refer to TestSuiteA/__init___.robot

Suite Setup      Check Variables Existence

*** Keywords ***
Check Variables Existence
    Variable Should Exist       \@{x}
    Variable Should Exist       \&{y}
    Variable Should Not Exist   \${z}
