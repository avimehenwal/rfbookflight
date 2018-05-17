*** Settings ***
Library             SeleniumLibrary
Library             DateTime
Library             Collections
Library             BuiltIn
#Test Setup         Reload Page
#Test Setup         Open Browser     ${SEARCH_URL}     ${BROWSER}
Suite Setup         Open Browser     ${HP_URL}         ${BROWSER}
Suite Teardown      Close All Browsers


*** Variables ***
# Test runner variables
${HP_URL}                 https://www.goibibo.com/
${SEARCH_URL}             https://www.goibibo.com/flights/air-BLR-BOM-20180517-20180519-1-0-0-E-D/
${BROWSER}                chrome
${TIMEOUT}                10

# Home page variables
${from_loc}               css=#gosuggest_inputSrc
${to_loc}                 css=#gosuggest_inputDest
${header_loc}             css=#searchWidgetNew > h1
${depart_return_loc}      css=input.form-control[placeholder="Choose Date"]
${from_val}               Bangalore (BLR)
${to_val}                 Mumbai (BOM)
${day_picker}             css=div.DayPicker
${tomorrow_loc}           ${day_picker} .DayPicker-Day--selected+div
${return_loc}             ${day_picker} .DayPicker-Day--today+div+div
${search_loc}             css=#gi_search_btn

# Search-results page variables
# Todo - why css locators are not iterable?
#${s_from_dep_loc}      css=#onwFltContainer>div>div>div>div>div.col-md-3:nth-child(1)>span:nth-child(1)
${s_from_dep_loc}       //*[@id="onwFltContainer"]//div[@class="col-md-3 col-sm-4 col-xs-4"]/span[1]
${s_sel_loc}            /../../../../../div[@class="card-block fl width100 padT20 padB15"]//label[@class="control control--radio"]
#${s_to_dep_loc}        css=#retFltContainer>div>div>div>div>div.col-md-3:nth-child(1)>span:nth-child(1)
${s_to_dep_loc}         //div[@id="retFltContainer"]//div[@class="col-md-3 col-sm-4 col-xs-4"]/span[1]

# Booking confirmation page
${total_price_loc}        css=#fareSummary span.fl
${proceed_to_pay_loc}     css=input[value="BOOK"]


*** Test Cases ***
Test making a sample booking from Bangalore to Mumbai - goibibo
    [Documentation]     Assert price and payment button after fligh destination and time selection.
    ...     Open goibibo homepage
    ...     Enter source:Bangalore and destination:Mumbai in input boxes
    ...     Select travel depart:tomorrow and return:tomorrow+2 from date-picker
    ...     Click "Get Set Go" button
    ...     Identify earliest depart flight time and select
    ...     Identify earliest return flight time and select
    ...     Click "Book" Button
    ...     From conformation page assert "Total Price" and "Proceed to Payment"

    Select City     ${from_loc}      ${from_val}
    Select City     ${to_loc}        ${to_val}

    : FOR       ${picker_position}    IN RANGE   0   1
    \   Log    ${picker_position}
    \  Select Date From Datepicker         ${tomorrow_loc}      ${picker_position}
    \  Select Date From Datepicker         ${return_loc}        ${picker_position}

    Click Element       ${search_loc}

    Get The Earliest Time         ${s_from_dep_loc}
    Get The Earliest Time         ${s_to_dep_loc}
    Click Element                 ${proceed_to_pay_loc}
    Wait Until Page Contains      Proceed to Payment

    # Assertions
    Page Should Contain           Proceed to Payment
    Element Should Be Visible     ${total_price_loc}        total price not visible


*** Keywords ***
Select Date From Datepicker
    [Arguments]       ${date_locator}           ${index}
    [Documentation]   Find and selects the date provides by locater on datepicker widget
    @{depart_return_datepicker_list} =   Get WebElements   ${depart_return_loc}
    Convert To Integer      ${index}
    Click Element   @{depart_return_datepicker_list}[${index}]
    Wait Until Element Is Visible      ${day_picker}     ${TIMEOUT}
    Page Should Contain Element        ${day_picker}
    Element Should Contain     ${day_picker}     May 2018
    Click Element           ${date_locator}
    Wait Until Page Does Not Contain Element        ${day_picker}     ${TIMEOUT}

Select City
    [Arguments]       ${locator}        ${value}
    [Documentation]   Locate the input field and selects the desired value
    Wait Until Page Contains        Book Domestic & International Flight       ${TIMEOUT}
    Input Text                      ${locator}      ${value}
    Wait Until Page Contains        ${value}
    Click Element                   ${header_loc}


Get The Earliest Time
    [Arguments]       ${locator}
    [Documentation]   Extract all depart-times from DOM
    ...               sort them, fetch the smallest one
    ...               and then select the containg tile
    ${xpath}=    Set Variable          ${locator}
    ${count}=    Get Matching Xpath Count    ${xpath}
    ${time}=     Create List
    Wait Until Page Contains      Bangalore to Mumbai       ${TIMEOUT}
    :FOR    ${i}    IN RANGE    1      ${count} + 1
    \    ${name}=    Get Text    xpath=(${xpath})[${i}]
    \    Append To List    ${time}     ${name}
    Log             ${time}
    Sort List       ${time}
    ${first}=       Get From List      ${time}     0
    ${first_loc}=   Set Variable       ${locator}[text()="${first}"]
    ${sel_first_loc}=       Set Variable      ${first_loc}${s_sel_loc}
    Log             ${sel_first_loc}
    Wait Until Element Is Enabled      ${sel_first_loc}       ${TIMEOUT}       not enabled
    Set Focus To Element               ${sel_first_loc}

    ${y}=    Get Vertical Position     ${sel_first_loc}
    ${yi}=    Evaluate        ${y}-250
    Log     ${yi}
    Execute Javascript        window.scrollTo(0, ${yi});
    Wait Until Element Is Visible       ${sel_first_loc}       ${TIMEOUT}
    # Todo - WebDriverException: Message: unknown error: Element is not clickable at point
    #Click Element           ${sel_first_loc}
    Execute Javascript   var j = document.evaluate ('${sel_first_loc}', document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null); j.click;
    Execute Javascript        window.scrollTo(0, 0);
