@isTest
public with sharing class ASDAC_CaseSelector_Test {
    
    @testSetup
    public static void createData() {
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        ocsTeamLdrTstUsr.FederationIdentifier = ocsTeamLdrTstUsr.FederationIdentifier + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEADUK_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            // create case 
            Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            List<Case> listOfCases = ASDAC_TestDataUtility.createCases(2, false, 'CustomerSupport', personAccount.Id);
            listOfCases[0].ContactReasonLevel1__c = 'Payment & Refunds';
            listOfCases[0].ContactReasonLevel2__c = 'VAT Receipt';
            listOfCases[0].SuppliedEmail = 'abc@asdatest.co.uk';
            listOfCases[0].Status = 'Assigned';
            listOfCases[0].OrderId__c = 'TestOrderId';
            listOfCases[1].ContactReasonLevel1__c = 'Payment & Refunds';
            listOfCases[1].ContactReasonLevel2__c = 'VAT Receipt';
            listOfCases[1].SuppliedEmail = 'abc@asdatest.co.uk';
            listOfCases[1].Status = 'Assigned';
            listOfCases[1].OrderId__c = 'TestOrderId1';
            listOfCases[1].IsVatReceiptGenerated__c = true;
            Test.startTest();
            insert listOfCases;
            Test.stopTest();
        }
    }

    @isTest
    static void testGetCase() {        
        // Call the method to be tested
        List<ASDAC_CaseSelector.CaseWrapper> result = ASDAC_CaseSelector.getCase('TestOrderId');
        // Assertions
        System.assertEquals(1, result.size(), 'Expected one Case record');
        System.assertEquals('Payment & Refunds', result[0].contactreasonLevel1, 'Case reason shoud match');
        // Add more assertions for other fields
    }
    
    @isTest
    static void testGetOrderIdForCase() {
        // Test data setup
        List<Case> caseList = [Select Id,OrderId__c from Case];
        // Call the method to be tested
        String result = ASDAC_CaseSelector.getOrderIdForCase(caseList, 'FallbackOrderId');
        // Assertions
        System.assertEquals('TestOrderId', result, 'Order Id should match');
    }
    
    @isTest
    static void testGetCaseList() {
        // Test data setup
        List<Case> caseList = [Select Id,OrderId__c from Case];
        // Call the method to be tested
        List<Case> fetchedCases = ASDAC_CaseSelector.getCaseList(caseList[0].Id);
        // Assertions
        System.assertEquals(caseList[0].Id, fetchedCases[0].Id, 'Order Id should match');
    }

    @isTest
    static void testGetVATParentCase() {        
        // Call the method to be tested
        String result = ASDAC_CaseSelector.getVATParentCase('TestOrderId', 'VAT Receipt');        
        // Assertions
        System.assertNotEquals('', result, 'VAT Case Id should not be empty');
        // test empty ID
        String result1 = ASDAC_CaseSelector.getVATParentCase('TestOrderId1', 'VAT Receipt');
        System.assertEquals('', result1, 'Empty case id');
        // test exception
        String result2 = ASDAC_CaseSelector.getVATParentCase('123654', 'TestInvalidReason');
        System.assertEquals(System.Label.ASDAC_VAtCaseNotFound, result2, 'no vat case found label');
    }
    
    @isTest
    static void testGetWebformCases() {
        // Test data setup
        List<Id> caseIds = new List<Id>();
        // Add Case Ids to the list
        Case testCase = [Select Id from Case limit 1];
        caseIds.add(testCase.Id);
        // Call the method to be tested
        List<List<Case>> result = ASDAC_CaseSelector.getWebformCases(new List<List<Id>>{caseIds});
        // Assertions
        System.assertEquals(testCase.Id, result[0][0].Id, 'Case Id should matched');
    }
}