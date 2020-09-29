*** Test Cases ***
Check Variables Existence
    Variable Should Exist       \@{x}
    Variable Should Exist       \&{y}
    Variable Should Not Exist   \${z}