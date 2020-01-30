*** Settings ***
Documentation     An example resource file
Library           SeleniumLibrary
Resource          topnav.resource

*** Variables ***
${URL}           https://www.amazon.com/
${BROWSER}        Firefox
${TITLE_TEXT}     Amazon

*** Keywords ***
Open Home Page
    [Documentation]    Opens browser to Amazons landing page
    Open Browser            ${URL}    ${BROWSER}

Search For A Product
    [Documentation]     Looks for ${SEARCH_TERM} in Amazons search bar
    Input Text          ${TOPNAV_SEARCH_BOX}   ${SEARCH_TERM}   # these are defined in topnav.resource
    Close Browser