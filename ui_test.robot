*** Settings ***
[Documentation]    UI Test AUtomation
Library           SeleniumLibrary
Library           Collections
Test Setup        Run Keywords    Open Browser    ${URL}    Chrome
...               AND    Verify BNZ Home page loading is complete
Test Teardown     Close All Browsers

*** Variables ***
${URL}            https://www.demo.bnz.co.nz/client/
${BROWSER}        Chrome    options=executable_path="/usr/local/bin/chromedriver";
${apm_name}       Vikramjeet Singh
${apm_bank}       12
${apm_branch}     3333
${apm_account}    4567890
${apm_suffix}     001

*** Test Cases ***
TC1: Verify you can navigate to Payees page using the navigation menu
    Navigate To Payees Page
    Wait Until Page Contains Element    xpath:.//input[@placeholder='Search payees'][@type='text']

TC2: Verify you can add new payee in the Payees page
    Navigate To Payees Page
    Add New Payee    ${apm_name}    ${apm_bank}    ${apm_branch}    ${apm_account}    ${apm_suffix}

TC3: Verify payee name is a required field
    Navigate To Payees Page
    Click Button    Add
    Click Button    Add
    Wait Until Element Is Visible    class:field-error
    ${error_text}=    Get Element Attribute    class:field-error    aria-label
    ${status}=    Run Keyword And Return Status    Should Be Equal As Strings    ${error_text}    Payee Name is a required field. Please complete to continue.
    ...    ignore_case=True    collapse_spaces=True
    Run Keyword If    ${status}    Input Text    name:apm-name    ${apm_name}
    Run Keyword If    ${status}    Press Keys    name:apm-name    RETURN
    Click Button    Add
    Wait Until Element Is Visible    class:field-error
    ${error_text}=    Get Element Attribute    class:field-error    aria-label
    ${status}=    Run Keyword And Return Status    Should Be Equal As Strings    ${error_text}    Bank Code is a required field. Please complete to continue.
    ...    ignore_case=True    collapse_spaces=True
    Run Keyword If    ${status}    Input Text    name:apm-bank    ${apm_bank}
    Input Text    name:apm-branch    ${apm_branch}
    Input Text    name:apm-account    ${apm_account}
    Input Text    name:apm-suffix    ${apm_suffix}
    Click Button    Add
    Wait Until Page Contains Element    id:notification    timeout=4seconds
    Wait Until Page Contains    Payee added    timeout=4seconds    error=Notification of payee added not seen on page
    Payee is added sucessfully    ${apm_name}

TC4: Verify that payees can be sorted by name
    Navigate To Payees Page
    ${test_apm_name}=    Set Variable    Aaaaaaa Aaaaa
    ${test_apm_account}=    Set Variable    7777777
    Add New Payee    ${test_apm_name}    ${apm_bank}    ${apm_branch}    ${apm_account}    ${apm_suffix}
    ${before_list}=    Get List of Current Payees
    ${first}=    Get From List    ${before_list}    0
    Should Be Equal As Strings    ${first}    ${test_apm_name}    #    Aaaaaaa Aaaaa is first element in list
    Click Element    class:js-payee-name-column.CustomSection-headingSpread.u-textStyle-bold    # Name sorting button
    ${after_list}=    Get List of Current Payees
    ${last}=    Get From List    ${after_list}    -1
    Should Be Equal As Strings    ${last}    ${test_apm_name}    #    is last element is list

TC5: Navigate to Payments page
    Navigate To Payments Page
    Click Button    Choose account
    Wait Until Page Contains Element    xpath:(.//span[contains(., 'From')])
    Sleep    1sec
    Click Button    Everyday
    Click Button    Choose account, payee, or someone new
    Wait Until Page Contains Element    xpath:(.//span[contains(., 'To')])
    Sleep    1sec
    Wait Until Page Contains    Payees
    Wait Until Page Contains    Accounts
    Click Element    xpath:.//span[contains(., 'Accounts')]
    Click Button    Bills
    Wait Until Page Contains Element    xpath:(.//span[contains(., 'Amount')])
    Sleep    1sec
    Input Text    id:field-bnz-web-ui-toolkit-9    500
    Click Button    Transfer
    #todo: check transfer amount

*** Keywords ***
Verify BNZ Home page loading is complete
    [Documentation]    Waits for Home page bnz to load completely
    Wait Until Page Contains Element    xpath:(.//span[contains(., 'Menu')])
    Wait Until Page Contains Element    xpath:(.//span[contains(., 'Overall')])
    Wait Until Page Contains Element    xpath:(.//span[contains(normalize-space(.), 'Quick pay')])[last()]

Navigate To Payees Page
    [Documentation]    Clicks Menu and Goes to Payees Page
    Click Element    xpath:(.//span[contains(., 'Menu')])    #Click ‘Menu’
    Wait Until Page Contains Element    xpath:.//span[contains(., 'Payees')]
    Click Link    /client/payees    #Click ‘Payees’
    Comment    Verify Payees page is loaded
    Location Should Contain    /client/payees    message=Verifies current URL contains payees

Navigate To Payments Page
    [Documentation]    Takes user to Pay or transfer page
    Click Element    xpath:(.//span[contains(., 'Menu')])    #Click ‘Menu’
    Click Element    class:js-main-menu-paytransfer.js-main-menu-primary-option    # Pay or transfer in menu
    Wait Until Location Contains    payments

Add New Payee
    [Arguments]    ${apm_name}    ${apm_bank}    ${apm_branch}    ${apm_account}    ${apm_suffix}
    Click Button    Add
    Wait Until Element Is Visible    id:apm-form    timeout=4seconds
    Click Element    id:apm-form
    Input Text    name:apm-name    ${apm_name}
    Press Keys    name:apm-name    RETURN
    Input Text    name:apm-bank    ${apm_bank}
    Input Text    name:apm-branch    ${apm_branch}
    Input Text    name:apm-account    ${apm_account}
    Input Text    name:apm-suffix    ${apm_suffix}
    Click Button    Add
    Wait Until Page Contains Element    id:notification    timeout=4seconds
    Wait Until Page Contains    Payee added    timeout=4seconds    error=Notification of payee added not seen on page
    Payee is added sucessfully    ${apm_name}

Payee is added sucessfully
    [Arguments]    ${payee_name}
    ${current_list_of_payees}=    Get List of Current Payees
    List Should Contain Value    ${current_list_of_payees}    ${payee_name}    msg=checks new payee is in list of current payees on page

Get List of Current Payees
    ${element_list_of_payees}=    Get WebElements    //*[@class="js-payee-name"]
    ${list_payees_names}=    Create List
    FOR    ${elem}    IN    @{element_list_of_payees}
        ${name}=    Get Text    ${elem}
        Append To List    ${list_payees_names}    ${name}
    END
    [Return]    ${list_payees_names}
