*** Settings ***
[Documentation]    API Test Automation forDatacom
Library           Collections
Library           RequestsLibrary
Library           FakerLibrary
Suite Setup       Create Session    jsonplaceholder    https://jsonplaceholder.typicode.com/users

*** Test Cases ***
TC1: Verify GET Users request
    ${resp}=    GET On Session    jsonplaceholder    /
    Comment    Verify 200 OK message is returned
    Status Should Be    200    ${resp}
    Should Be Equal As Strings    OK    ${resp.reason}
    Comment    Verify that there are 10 users in the results
    Length Should Be    ${resp.json()}    10    msg=Number of items not 10

TC2: Verify GET User request by Id
    ${resp}=    GET On Session    jsonplaceholder    /
    Comment    Verify 200 OK message is returned
    Status Should Be    200    ${resp}
    ${expected_user}=    Set Variable    Nicholas Runolfsdottir V
    ${data}=    Set Variable    ${resp.json()}
    FOR    ${item}    IN    @{data}
        ${user_id}=    Get From Dictionary    ${item}    id
        ${user_name}=    Get From Dictionary    ${item}    name
        ${id_status}=    Run Keyword And Return Status    Should Be Equal As Integers    ${user_id}    8
        Comment    Verify if user with id8 is Nicholas Runolfsdottir V
        Run Keyword If    ${id_status}    Should Be Equal As Strings    ${user_name}    ${expected_user}
    END

TC3: Verify POST Users request
    Comment    TODO:Use fakerlibrary(https://guykisel.github.io/robotframework-faker/) for random data generation/parameterized
    ${dict_address}=    Create Dictionary    "street"="29 Street"    "suite"="Suite 2"    "city"="Hamilton"    "zipcode"="58804-1099"
    ${dict_geo}=    Create Dictionary    "lat"="24.8918"    "lng"="21.8984"
    ${dict_company}=    Create Dictionary    "name"="RTtech Group"    "catchPhrase"="Configurable multimedia task-force"    "bs"="generate enterprise e-tailers"
    ${dict_data}=    Create Dictionary    "id"=11    "name"="Vikramjeet Singh"    "username"="vikram"    "email"="vikram.jeet@gmail.com"
    ...    "address"=${dict_address}    "geo"=${dict_geo}    "phone"="210.067.6132"    "website"="vikram.io"    "company"=${dict_company}
    ${resp}=    POST On Session    jsonplaceholder    /    json=${dict_data}
    Comment    Verify 201 OK message is returned
    Status Should Be    201    ${resp}
