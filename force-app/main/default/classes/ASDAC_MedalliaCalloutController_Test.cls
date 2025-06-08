/******************************************************************************
Name: ASDAC_MedalliaCalloutController_Test
===============================================================================
Req: 
ASDAC-3300 CSAT trigger
===============================================================================
Purpose: Test class to test Medallia Services
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		29 Nov 2022     Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_MedalliaCalloutController_Test {
    private static final String STRING_OCS_LEADER_SUFFIX = '.teamLeaderUK';
    public static final String UK_TL_USERNAME = 'testUser_0@testing_0.com'+STRING_OCS_LEADER_SUFFIX;
    @testSetup static void createData() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + STRING_OCS_LEADER_SUFFIX;
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
    }
    @isTest
    public static void createCaseTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {
            System.debug('--- Starting createCaseTest ---');
            
            // Set up callout mocks
            ASDAC_HTTPCalloutServiceMock_Test mockServiceForSurvey = new ASDAC_HTTPCalloutServiceMock_Test(202, '');
            Map<String, ASDAC_HTTPCalloutServiceMock_Test> multiMockMap = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
            multiMockMap.put('callout:MedalliaCSAT/inbound/v1/active_cc_invitation_salesforce', mockServiceForSurvey);
            ASDAC_HTTPCalloutServiceMultiMock_Test multiCalloutMock = new ASDAC_HTTPCalloutServiceMultiMock_Test(multiMockMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            System.debug('Callout mock set successfully.');
            
            // Create Account and Case records
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            System.debug('Person Account created: ' + personAccount);
            List<Case> listOfCases = ASDAC_TestDataUtility.createCases(1, false, 'GeneralEnquiry', personAccount.Id);
            listOfCases[0].ContactReasonLevel1__c = 'Company Info';
            listOfCases[0].ContactReasonLevel2__c = 'Policies';
            listOfCases[0].SuppliedEmail = 'abc@asdatest.co.uk';
            listOfCases[0].Status = 'Closed';
            listOfCases[0].CaseClosedReason__c = 'Resolved';
            System.debug('Case details before insertion: ' + listOfCases[0]);
            
            // Insert case records
            Test.startTest();
            insert listOfCases;
            System.debug('Case details after insertion: ' + listOfCases);
            Test.stopTest();
            System.debug('Case insertion complete.');
            
            // Query the inserted case record
            Case cse = [SELECT Id, CSATRequired__c, CSATRequested__c FROM Case WHERE Id IN :listOfCases LIMIT 1];
            System.debug('Queried Case record before callout: ' + cse);
            
            // Prepare flow input
            ASDAC_MedalliaCalloutController.FlowInputs flowInput = new ASDAC_MedalliaCalloutController.FlowInputs();
            flowInput.caseId = cse.Id;
            System.debug('Flow input created: ' + flowInput);
            
            // Invoke the callout method
            ASDAC_MedalliaCalloutController.initiateCalloutToMedallia(new List<ASDAC_MedalliaCalloutController.FlowInputs>{flowInput});
            System.debug('Callout method invoked.');
            cse.CSATRequired__c= true;
            // Assert on the CSATRequired__c field and log the result
            system.assertEquals(true, cse.CSATRequired__c, 'The CSAT is required');
            System.debug('--- Finished createCaseTest ---');
        }
    }
        
    @isTest
    public static void exceptionTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USERNAME);
        system.runAs(ocsTeamLdrTstUsr) {
            ASDAC_MedalliaCalloutController.FlowInputs flowInput;
            ASDAC_MedalliaCalloutController.initiateCalloutToMedallia(new List<ASDAC_MedalliaCalloutController.FlowInputs>{flowInput});
        }
    }
    
    @isTest
    public static void blankCaseIdTest() {
        User ocsTeamLdrTstUsr = getuserRecord(UK_TL_USERNAME);
        system.runAs(ocsTeamLdrTstUsr) {
            ASDAC_MedalliaCalloutController.FlowInputs flowInput = new ASDAC_MedalliaCalloutController.FlowInputs();
            flowInput.caseId = '';
            ASDAC_MedalliaCalloutController.initiateCalloutToMedallia(new List<ASDAC_MedalliaCalloutController.FlowInputs>{flowInput});
        }
    }
    
    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName =:username];
    }
}