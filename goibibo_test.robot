*** Settings ***
Library             SeleniumLibrary
Library             DateTime
Library             Collections
Library             BuiltIn
#Test Setup         Reload Page
#Test Setup         Open Browser     ${SEARCH_URL}     ${BROWSER}
Suite Setup         Goto Website
Suite Teardown      Close All Browsers


*** Variables ***
# Test runner variables
${Selenium.RemoteUrl}     http://localhost:4444/wd/hub
${HP_URL}                 https://www.goibibo.com/
${SEARCH_URL}             https://www.goibibo.com/flights/air-BLR-BOM-20180519-20180522-1-0-0-E-D/
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
${tomorrow_loc}           ${day_picker} #fare_20180519
${return_loc}             ${day_picker} #fare_20180522
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
Test a sample booking from Bangalore to Mumbai - goibibo
    [Documentation]     Assert price and payment button after fligh destination and time selection.
    ...     Open goibibo homepage
    ...     Enter source:Bangalore and destination:Mumbai in input boxes
    ...     Select travel depart:tomorrow and return:tomorrow+2 from date-picker
    ...     Click "Get Set Go" button
    ...     Identify earliest depart flight time and select
    ...     Identify earliest return flight time and select
    ...     Click "Book" Button
    ...     From conformation page assert "Total Price" and "Proceed to Payment"
    #[Setup]             Goto Website
    Select City         ${from_loc}   ${from_val}
    Select City         ${to_loc}     ${to_val}
    Select Date From Datepicker       ${tomorrow_loc}      ${0}
    Select Date From Datepicker       ${return_loc}        ${1}
    Click Element       ${search_loc}
    Get The Earliest Time New         ${s_from_dep_loc}
    Get The Earliest Time New         ${s_to_dep_loc}
    Click Element                     ${proceed_to_pay_loc}
    Wait Until Page Contains          Proceed to Payment
    # Assertions
    Page Should Contain               Proceed to Payment
    Element Should Be Visible         ${total_price_loc}        total price not visible

Dummy Test Case
    [Tags]      test
    [Setup]     Open Browser     ${SEARCH_URL}     ${BROWSER}       remote_url=${Selenium.RemoteUrl}
    Get The Earliest Time New     ${s_from_dep_loc}
    Get The Earliest Time New     ${s_to_dep_loc}

*** Keywords ***
Scroll Element To Top
    [Arguments]       ${locator}        ${padding_from_top}=250
    [Documentation]   Scroll screen to until locator is on top
    ...               Overcomes item not clickable / overlapping element issues
    ...               250 padding required on search-result page
    ${y}=    Get Vertical Position     ${locator}
    ${yi}=    Evaluate        ${y}-${padding_from_top}
    Log     ${yi}
    Execute Javascript        window.scrollTo(0, ${yi});

Select Date From Datepicker
    [Arguments]       ${date_locator}           ${index}
    [Documentation]   Find and selects the date provides by locater on datepicker widget
    @{depart_return_datepicker_list} =   Get WebElements   ${depart_return_loc}
    Convert To Integer      ${index}
    Click Element   @{depart_return_datepicker_list}[${index}]
    Wait Until Element Is Visible      ${date_locator}     ${TIMEOUT}
    Page Should Contain Element        ${date_locator}
    Element Should Contain             ${day_picker}       2018
    Scroll Element To Top              ${date_locator}
    #Wait Until Keyword Succeeds    3    2 sec     Click Element     ${date_locator}
    Click Element     ${date_locator}
    Wait Until Page Does Not Contain Element        ${day_picker}     ${TIMEOUT}
    Execute Javascript        window.scrollTo(0, 0);

Select City
    [Arguments]       ${locator}        ${value}
    [Documentation]   Locate the input field and selects the desired value
    Wait Until Page Contains        Book Domestic & International Flight       ${TIMEOUT}
    Input Text                      ${locator}      ${value}
    Wait Until Page Contains        ${value}
    Click Element                   ${header_loc}

Goto Website
    #Open Browser     ${HP_URL}   ${BROWSER}
    #Open Browser     ${SEARCH_URL}     ${BROWSER}
    Open Browser     ${HP_URL}   ${BROWSER}   remote_url=${Selenium.RemoteUrl}
    Maximize Browser Window

Get The Earliest Time New
    [Arguments]       ${locator}
    [Documentation]   Extract all depart-times from DOM
    ...               sort them, fetch the smallest one
    ...               and then select the containing tile
    Log     ${locator}
    Wait Until Page Contains      Bangalore to Mumbai       ${TIMEOUT}
    Wait Until Page Contains Element     ${locator}
    @{elements}=     Get WebElements     ${locator}
    Log Many    @{elements}
    ${count}=        Get Length     ${elements}
    Log     ${count}
    ${time}=     Create List
    :FOR    ${element}    IN   @{elements}
    \    Log    ${element}
    \    ${name}=    Get Text     ${element}
    \    Append To List    ${time}     ${name}
    Log             ${time}
    Sort List       ${time}
    Log             ${time}
    ${first}=       Get From List      ${time}     0
    Log     ${first}
    ${first_loc}=   Set Variable       ${locator}[text()="${first}"]
    Log     ${first_loc}
    ${sel_first_loc}=       Set Variable      ${first_loc}${s_sel_loc}
    Log             ${sel_first_loc}
    Wait Until Element Is Enabled      ${sel_first_loc}       ${TIMEOUT}       not enabled
    Set Focus To Element               ${sel_first_loc}
    Scroll Element To Top              ${sel_first_loc}
    Wait Until Element Is Visible      ${sel_first_loc}       ${TIMEOUT}
    # Todo - WebDriverException: Message: unknown error: Element is not clickable at point
    #Click Element           ${sel_first_loc}
    Execute Javascript   var j=document.evaluate ('${sel_first_loc}', document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null); j.click;
    Execute Javascript        window.scrollTo(0, 0);
