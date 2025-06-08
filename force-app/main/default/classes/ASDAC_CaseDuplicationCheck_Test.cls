/*************************************************************************
Name: ASDAC_CaseDuplicationCheck_Test
==========================================================================
Req: 
ASDAC-1202 Enhancement- Agents can follow case updates.
==========================================================================
Purpose: This Class will test the functionality ASDAC_CaseDuplicationCheck Controller class   
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                        DATE            DETAIL
1.0       Sanskriti Vijay                20-Sept-2022    Initial Development
**************************************************************************/
@isTest
public with sharing class ASDAC_CaseDuplicationCheck_Test {
    public static final String BPO_Colleague_USERNAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
 
    @TestSetup
    static void createData(){
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
 
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO}, ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
    }
 
    private static User getUserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
 
    @IsTest
    static void upsertWebformListOfCasesTest() {
        // Create test data
        User ocsCollBPO = getUserRecord('testUser_0@testing_0.com.ocsColleagueBPO');
        List<Case> caseList = new List<Case>();
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Status = 'Assigned';
        testCase.Origin = 'Webform';
        testCase.OwnerId = ocsCollBPO.Id; // Set the OwnerId to the created user
 
        caseList.add(testCase);
 
        List<List<Case>> caseObjectList = new List<List<Case>>();
        caseObjectList.add(caseList);
 
        System.runAs(ocsCollBPO) {
            Test.startTest();
            System.debug('Before upsert, caseList size: ' + caseList.size());
            ASDAC_CaseDuplicationCheck.upsertWebformListOfCases(caseObjectList);
            Test.stopTest();
        }
 
        List<Case> updatedCases = [SELECT Id, Subject, Status FROM Case WHERE Subject = 'Test Case'];
        System.debug('updatedCases.size -----------------> ' + updatedCases.size());
        System.debug('updatedCases -----------------> ' + updatedCases);
        System.assertEquals(1, updatedCases.size(), 'Expected one case to be upserted');
        System.assertEquals('Test Case', updatedCases[0].Subject, 'Unexpected case subject');
        System.assertEquals('Assigned', updatedCases[0].Status, 'Unexpected case status');
    }
}